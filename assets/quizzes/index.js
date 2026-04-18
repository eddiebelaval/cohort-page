// Quizzes module — Daily Quiz for CCA-F Exam Prep
// Owner: Allie (@allierays)
// See docs/superpowers/specs/2026-04-16-quizzes-spec.md

// ── Constants ──

const DAILY_COUNT = 5;
const PASS_THRESHOLD = 0.7; // 70% to "pass"
const HISTORY_DAYS = 7;

const DOMAINS = {
  agentic_architecture:  { label: 'Agentic Architecture',  weight: 27 },
  tool_design_mcp:       { label: 'Tool Design & MCP',     weight: 18 },
  claude_code_config:    { label: 'Claude Code Config',     weight: 20 },
  prompt_engineering:    { label: 'Prompt Engineering',     weight: 20 },
  context_management:    { label: 'Context Management',     weight: 15 },
};

const LETTERS = ['A', 'B', 'C', 'D'];

// ── Hardcoded question bank (works without Supabase) ──
// These are used as a fallback when the DB tables aren't set up yet.
// Once seed.sql is run in Supabase, the DB questions take priority.

const FALLBACK_QUESTIONS = [
  {
    id: 'fb-1', domain: 'agentic_architecture',
    scenario: 'You are building an agentic loop that processes customer refund requests. The agent has access to tools for looking up orders, verifying eligibility, and issuing refunds. In production, you notice the agent occasionally processes refunds for orders that have already been refunded, because it skips the eligibility check tool and calls the refund tool directly.',
    prompt: 'What change would most effectively prevent duplicate refunds?',
    options: [
      'Add a strongly worded instruction to the system prompt stating that the agent must always verify eligibility before processing any refund',
      'Implement a programmatic prerequisite in your agentic loop that blocks the refund tool until the eligibility check tool has returned a verified status',
      'Add few-shot examples showing the agent always calling the eligibility check before the refund tool',
      'Deploy a separate validation agent that reviews each refund decision before it is executed'
    ],
    correct_index: 1,
    explanation: 'When a specific tool sequence is required for critical business logic, programmatic enforcement provides deterministic guarantees. Options A and C rely on probabilistic LLM compliance, which is insufficient when errors have financial consequences. Option D is over-engineered — a simple prerequisite check in the loop is the proportionate fix.'
  },
  {
    id: 'fb-2', domain: 'agentic_architecture',
    scenario: 'Your multi-agent system has a coordinator that spawns subagents for different tasks. A web search subagent times out while researching a complex topic. You need to design how this failure information flows back to the coordinator so it can make intelligent recovery decisions.',
    prompt: 'Which error propagation approach best enables the coordinator to recover?',
    options: [
      'Return structured error context including the failure type, attempted query, any partial results, and suggested alternative approaches',
      'Implement automatic retry logic with exponential backoff within the subagent, returning a generic "search unavailable" status only after all retries are exhausted',
      'Catch the timeout within the subagent and return an empty result set marked as successful to avoid disrupting the coordinator',
      'Propagate the raw timeout exception directly to a top-level error handler that logs the failure and terminates the workflow'
    ],
    correct_index: 0,
    explanation: 'Structured error context gives the coordinator the information it needs to make intelligent recovery decisions — whether to retry with a modified query, try an alternative approach, or proceed with partial results. Option B hides valuable context behind a generic status. Option C suppresses the error entirely, risking incomplete outputs. Option D terminates the workflow unnecessarily when recovery strategies could succeed.'
  },
  {
    id: 'fb-3', domain: 'tool_design_mcp',
    scenario: 'Your agent has two tools: get_customer (retrieves customer information) and lookup_order (retrieves order details). Production logs show the agent frequently calls get_customer when users ask about orders (e.g., "check my order #12345"). Both tools have minimal descriptions: "Retrieves customer information" and "Retrieves order details."',
    prompt: 'What is the most effective first step to improve tool selection accuracy?',
    options: [
      'Add few-shot examples to the system prompt demonstrating correct tool selection with 5-8 examples',
      'Expand each tool\'s description to include input formats, example queries, boundaries, and when to use it versus similar tools',
      'Implement a routing layer that parses user input and pre-selects the appropriate tool based on keyword matching',
      'Consolidate both tools into a single lookup_entity tool that internally routes to the correct backend'
    ],
    correct_index: 1,
    explanation: 'Tool descriptions are by far the most important factor in tool selection. When descriptions are minimal, the model lacks context to differentiate between similar tools. Expanding descriptions is a low-effort, high-leverage fix. Option A adds token overhead without fixing the underlying issue. Option C bypasses the LLM\'s natural language understanding. Option D is valid but more effort than a first step warrants.'
  },
  {
    id: 'fb-4', domain: 'claude_code_config',
    scenario: 'You want to create a custom /review slash command that runs your team\'s standard code review checklist. This command should be available to every developer on the team when they clone or pull the repository.',
    prompt: 'Where should you place this command file?',
    options: [
      'In ~/.claude/commands/ in each developer\'s home directory',
      'In .claude/commands/ in the project repository',
      'In the CLAUDE.md file at the project root as a section under "Commands"',
      'In .claude/config.json with a commands array defining the command'
    ],
    correct_index: 1,
    explanation: 'Project-scoped custom slash commands belong in .claude/commands/ within the repository — they are version-controlled and automatically available to all developers who clone or pull. Option A is for personal commands not shared via version control. Option C is for project instructions, not command definitions. Option D describes a configuration mechanism that does not exist.'
  },
  {
    id: 'fb-5', domain: 'claude_code_config',
    scenario: 'Your team integrates Claude Code into the CI pipeline for automated code reviews on pull requests. The pipeline script runs: claude "Analyze this pull request for security issues" but the job hangs indefinitely. Logs show Claude Code is waiting for interactive input.',
    prompt: 'What is the correct fix to run Claude Code in a CI pipeline?',
    options: [
      'Set the environment variable CLAUDE_HEADLESS=true before running the command',
      'Add the -p flag: claude -p "Analyze this pull request for security issues"',
      'Redirect stdin from /dev/null: claude "Analyze..." < /dev/null',
      'Add the --batch flag: claude --batch "Analyze this pull request for security issues"'
    ],
    correct_index: 1,
    explanation: 'The -p (--print) flag runs Claude Code in non-interactive mode — it processes the prompt, outputs to stdout, and exits without waiting for user input. This is the documented approach for CI/CD. Options A, C, and D reference non-existent features or Unix workarounds that don\'t properly address Claude Code\'s command interface.'
  },
  {
    id: 'fb-6', domain: 'prompt_engineering',
    scenario: 'You are building a document processing pipeline that extracts structured data from legal contracts. The output must conform to a strict JSON schema with specific field types and required fields. Any deviation from the schema causes downstream processing failures.',
    prompt: 'Which approach guarantees schema conformance in the output?',
    options: [
      'Add the JSON schema to the system prompt and instruct Claude to follow it exactly',
      'Use output_config with format type json_schema and provide the full schema definition for constrained decoding',
      'Provide 3-5 few-shot examples of correct JSON output in the prompt',
      'Implement client-side JSON validation that retries until the output matches the schema'
    ],
    correct_index: 1,
    explanation: 'output_config with json_schema type provides guaranteed schema conformance through constrained decoding — the output literally cannot deviate from the schema. Option A relies on instruction following, which is probabilistic. Option C helps but doesn\'t guarantee conformance. Option D catches errors but adds latency from retries.'
  },
  {
    id: 'fb-7', domain: 'prompt_engineering',
    scenario: 'Your team wants to reduce API costs for two Claude-powered workflows: (1) a blocking pre-merge code review check that must complete before developers can merge PRs, and (2) a weekly technical debt report generated Sunday night for Monday morning review. Your manager proposes switching both to the Message Batches API for its 50% cost savings.',
    prompt: 'How should you evaluate this proposal?',
    options: [
      'Switch both workflows to batch processing — the 50% savings applies to all usage and most batches complete quickly',
      'Use batch processing for the technical debt reports only; keep real-time API calls for pre-merge checks',
      'Keep real-time calls for both — batch processing introduces ordering issues that could affect code review accuracy',
      'Switch both to batch processing with a fallback to real-time if the batch takes longer than 30 minutes'
    ],
    correct_index: 1,
    explanation: 'The Batch API offers 50% savings but has processing times up to 24 hours with no guaranteed latency. This makes it unsuitable for blocking pre-merge checks where developers wait, but ideal for overnight/weekly reports. Option A ignores that blocking workflows can\'t tolerate variable latency. Option C incorrectly claims ordering issues. Option D adds complexity when the simpler solution is matching each API to its use case.'
  },
  {
    id: 'fb-8', domain: 'context_management',
    scenario: 'Your agent is in a long-running session that has accumulated 140,000 tokens of conversation history. You have compaction configured with the default trigger threshold. The model is Claude Opus 4.6 with a 1M token context window.',
    prompt: 'At what point will compaction be triggered, and what happens when it fires?',
    options: [
      'Compaction triggers at 140,000 tokens (current level) and removes all messages, starting a fresh context',
      'Compaction triggers at the default threshold of 150,000 tokens — it creates a compaction block summarizing the conversation, and all message blocks prior to it are dropped on subsequent requests',
      'Compaction triggers when the context window is 50% full (500,000 tokens) to maintain a safety buffer',
      'Compaction triggers continuously, summarizing every 10,000 tokens of new content to keep the context lean'
    ],
    correct_index: 1,
    explanation: 'The default compaction trigger is 150,000 tokens (minimum configurable: 50,000). When triggered, it creates a compaction block containing a conversation summary, and the API automatically drops all prior message blocks on subsequent requests. Option A is premature and destructive. Option C uses the wrong threshold. Option D describes continuous summarization, not how compaction works.'
  },
  {
    id: 'fb-9', domain: 'context_management',
    scenario: 'A pull request modifies 14 files across a stock tracking module. Your single-pass automated review produces inconsistent results: detailed feedback for some files but superficial comments for others, and contradictory feedback — flagging a pattern as problematic in one file while approving identical code elsewhere.',
    prompt: 'How should you restructure the review to address this inconsistency?',
    options: [
      'Switch to a model with a larger context window to give all 14 files adequate attention in one pass',
      'Split into focused passes: analyze each file individually for local issues, then run a separate integration pass examining cross-file data flow',
      'Require developers to split large PRs into smaller submissions of 3-4 files before automated review runs',
      'Run three independent review passes on the full PR and only flag issues that appear in at least two passes'
    ],
    correct_index: 1,
    explanation: 'Splitting reviews into focused passes directly addresses attention dilution — the root cause when processing many files at once. File-by-file analysis ensures consistent depth, while a separate integration pass catches cross-file issues. Option A misunderstands that larger windows don\'t solve attention quality. Option C shifts burden to developers. Option D would suppress detection of real bugs by requiring consensus.'
  },
  {
    id: 'fb-10', domain: 'agentic_architecture',
    scenario: 'You are building a customer support agent that handles account changes including email updates, password resets, and account deletions. Account deletions are irreversible and affect billing. Your team wants the agent to handle all three operations autonomously to minimize support queue wait times.',
    prompt: 'What is the most appropriate architecture for handling account deletions?',
    options: [
      'Allow the agent to process all operations autonomously since the user explicitly requested the deletion',
      'Implement a human-in-the-loop checkpoint that pauses the agent and requires a support manager to approve account deletions before execution',
      'Add a 24-hour cooling-off period where the deletion is queued and automatically executed if the user does not cancel',
      'Have the agent confirm the deletion request three times with the user before processing to ensure intent'
    ],
    correct_index: 1,
    explanation: 'Human-in-the-loop is the correct pattern for irreversible, high-stakes actions with billing impact. The agent should pause and escalate rather than act autonomously. Option A ignores the irreversibility risk. Option C delays but doesn\'t add human oversight. Option D adds friction without human judgment — multiple confirmations don\'t substitute for human review.'
  },
  {
    id: 'fb-11', domain: 'tool_design_mcp',
    scenario: 'You want to guarantee that Claude\'s tool calls always match your schema exactly — no missing required fields, no extra fields, no type mismatches. Your application processes financial data where malformed tool calls could cause incorrect calculations.',
    prompt: 'Which feature provides this guarantee?',
    options: [
      'Setting tool_choice to "tool" to force the model to always use the specific tool',
      'Enabling strict: true on the tool definition, which uses constrained decoding to guarantee schema conformance',
      'Adding JSON Schema validation to the tool description text so the model understands the requirements',
      'Implementing client-side validation that rejects and retries malformed tool calls until they conform'
    ],
    correct_index: 1,
    explanation: 'strict: true enables constrained decoding, which guarantees tool call outputs match the schema exactly through grammar-level enforcement. Option A forces tool use but doesn\'t guarantee the schema of the call. Option C relies on the model reading and following the description, which is probabilistic. Option D catches errors after generation rather than preventing them.'
  },
  {
    id: 'fb-12', domain: 'claude_code_config',
    scenario: 'Your codebase has distinct areas with different coding conventions: React components use functional style with hooks, API handlers use async/await with specific error handling, and test files are spread throughout the codebase alongside the code they test (e.g., Button.test.tsx next to Button.tsx). You want Claude to automatically apply the correct conventions based on what file it is working with.',
    prompt: 'What is the most effective way to configure this?',
    options: [
      'Create separate CLAUDE.md files in each subdirectory containing area-specific conventions',
      'Create .claude/rules/ files with YAML frontmatter specifying glob patterns (e.g., **/*.test.tsx) to conditionally apply conventions based on file paths',
      'Consolidate all conventions in the root CLAUDE.md under headers for each area, relying on Claude to infer which applies',
      'Create .claude/skills/ for each code type that include the relevant conventions'
    ],
    correct_index: 1,
    explanation: '.claude/rules/ with glob patterns allows conventions to be automatically applied based on file paths regardless of directory location — essential for test files spread throughout the codebase. Option A can\'t handle files spread across many directories. Option C relies on inference rather than explicit matching. Option D requires manual invocation or uncertain automatic loading.'
  },
  {
    id: 'fb-13', domain: 'prompt_engineering',
    scenario: 'You are processing a long document (80,000 tokens) with a query asking Claude to extract specific data points. You notice that extraction accuracy is significantly worse for information in the middle of the document compared to the beginning and end.',
    prompt: 'What is the most effective way to improve extraction accuracy across the entire document?',
    options: [
      'Increase max_tokens to give Claude more space to process the full document',
      'Restructure the request to place the document content at the top and the extraction query at the end of the prompt',
      'Split the document into smaller chunks and process each independently',
      'Enable extended thinking so Claude can reason more carefully about the middle sections'
    ],
    correct_index: 1,
    explanation: 'Placing documents above queries/instructions improves quality by up to 30% for long-context processing. This addresses the "lost in the middle" effect by ensuring the query comes after all content has been processed. Option A doesn\'t affect input processing quality. Option C loses cross-reference context. Option D doesn\'t specifically address positional attention patterns.'
  },
  {
    id: 'fb-14', domain: 'tool_design_mcp',
    scenario: 'Your MCP tool for querying a database sometimes returns errors. Currently, when a query fails, the tool returns: {"error": "failed"}. The agent retries the same failing query repeatedly without adjusting its approach.',
    prompt: 'How should you improve the error response to enable better agent recovery?',
    options: [
      'Return the raw database error message and stack trace so the agent has full debugging information',
      'Return a structured error with is_error: true, an error category, whether the error is retryable, and a suggested correction',
      'Implement automatic retry logic inside the tool with exponential backoff so the agent never sees errors',
      'Return a successful response with an empty result set and a warning field indicating the query had issues'
    ],
    correct_index: 1,
    explanation: 'Structured error responses with actionable information enable the agent to correct its approach. Specifying available columns lets the agent fix the query. Option A may include sensitive information and is unstructured. Option C hides errors and prevents the agent from learning. Option D suppresses errors by marking failures as successes.'
  },
  {
    id: 'fb-15', domain: 'context_management',
    scenario: 'Your agent uses extended thinking during multi-turn conversations with tool use. After a tool call cycle completes, you notice that the conversation history has grown significantly due to thinking blocks from previous turns.',
    prompt: 'How should thinking blocks be managed across turns to optimize context usage?',
    options: [
      'Keep all thinking blocks in the conversation history to maintain full reasoning context',
      'Thinking blocks from previous turns are automatically stripped by the API. However, during an active tool use cycle, the thinking block accompanying the tool request MUST be included with the tool result.',
      'Remove all thinking blocks after each turn to minimize context usage',
      'Thinking blocks should be summarized and included as a system message for the next turn'
    ],
    correct_index: 1,
    explanation: 'The API automatically strips thinking blocks between turns. The critical exception: during tool use, the thinking block that accompanies a tool request must remain paired with its tool result (verified by cryptographic signatures). Option A wastes context. Option C is too aggressive during tool use. Option D adds unnecessary complexity.'
  },
  {
    id: 'fb-16', domain: 'agentic_architecture',
    scenario: 'Your customer support agent processes billing disputes by calling tools like lookup_order, get_invoice, and process_refund. A code review reveals that after each tool call, your loop checks whether Claude\'s response text contains the phrase "I have completed" to decide whether to stop iterating.',
    prompt: 'What is the primary problem with this loop termination approach?',
    options: [
      'The agent will never terminate because process_refund always returns a success message',
      'Relying on natural language signals in the assistant\'s text is unreliable; the correct approach is to inspect stop_reason and only terminate when it equals end_turn',
      'The loop should terminate as soon as any tool call fails',
      'Checking response text is only valid in synchronous mode'
    ],
    correct_index: 1,
    explanation: 'Inspecting stop_reason is the canonical method for agentic loop control. Parsing natural language is unreliable — the model may phrase completion differently or include similar phrases mid-task.'
  },
  {
    id: 'fb-17', domain: 'tool_design_mcp',
    scenario: 'Your check_fraud_risk MCP tool returns {"isError": true, "message": "Refund blocked"} when an item is flagged for fraud. The agent retries three times, each retry generating a new fraud alert in the backend system.',
    prompt: 'What is missing from the error response that would prevent unnecessary retries?',
    options: [
      'A retry_after timestamp indicating when to try again',
      'An isRetryable: false flag and a customer-appropriate explanation distinguishing a business rule block from a transient error',
      'A return as successful with a blocked: true field instead of an error',
      'A fraud risk score so the agent can decide whether to retry'
    ],
    correct_index: 1,
    explanation: 'The agent retries because it doesn\'t know the error is a permanent business rule, not a transient failure. Adding isRetryable: false explicitly tells the agent not to retry. Option A implies retrying later is appropriate. Option C hides the error. Option D gives the agent information it shouldn\'t act on.'
  },
  {
    id: 'fb-18', domain: 'claude_code_config',
    scenario: 'Your /analyze-codebase skill produces hundreds of lines of intermediate output while exploring the codebase. After the skill runs, subsequent responses in the conversation are degraded because the exploration output pollutes the context window.',
    prompt: 'Which SKILL.md frontmatter setting fixes this while maintaining the skill\'s capabilities?',
    options: [
      'Set allowed-tools: [] to prevent the skill from using any tools',
      'Set context: fork to run the skill in an isolated subagent so its verbose output stays contained',
      'Move the skill from .claude/skills/ to .claude/commands/ for automatic context isolation',
      'Add argument-hint to skip context inheritance from the main conversation'
    ],
    correct_index: 1,
    explanation: 'context: fork runs the skill in an isolated subagent. The verbose intermediate output stays in the fork — only the final result returns to the main conversation. Option A breaks the skill. Option C doesn\'t provide isolation. Option D doesn\'t exist as described.'
  },
  {
    id: 'fb-19', domain: 'prompt_engineering',
    scenario: 'Your extraction pipeline uses a prompt requesting Claude to output JSON wrapped in a code block. In production, 3% of responses have JSON syntax errors — missing quotes, trailing commas, or unclosed brackets — causing downstream parsing failures.',
    prompt: 'What change most effectively eliminates these syntax errors?',
    options: [
      'Add a validation step that retries up to 3 times when JSON parsing fails',
      'Switch to tool use with a defined JSON schema as the input parameter, which guarantees valid JSON through constrained decoding',
      'Add an instruction to the prompt telling Claude to double-check its JSON syntax',
      'Implement a regex post-processor that fixes common JSON syntax errors'
    ],
    correct_index: 1,
    explanation: 'Tool use with a defined JSON schema guarantees valid JSON through constrained decoding — syntax errors become impossible. Option A catches errors but doesn\'t prevent them. Option C is probabilistic. Option D is fragile and can\'t handle all malformation patterns.'
  },
  {
    id: 'fb-20', domain: 'context_management',
    scenario: 'You completed a research investigation and identified two potential architectural approaches from the same baseline findings. You want to explore both approaches independently without one exploration\'s context contaminating the other.',
    prompt: 'Which session management approach is most appropriate?',
    options: [
      'Start two new sessions and copy-paste the research findings into each',
      'Use --resume twice to create two parallel sessions from the same point',
      'Use fork_session to create independent branches from the current session state',
      'Continue in the same session, using /compact between the two explorations'
    ],
    correct_index: 2,
    explanation: 'fork_session creates independent branches that share the same baseline context but diverge independently — exactly what\'s needed for parallel exploration without contamination. Option A loses tool call context. Option B isn\'t how --resume works. Option D risks context bleed despite compaction.'
  },
  // ── Domain deep-dive questions ──
  {
    id: 'fb-21', domain: 'tool_design_mcp',
    scenario: 'A junior developer needs to fix a bug on line 42 of a configuration file. They use the Write tool to output the entire file with the fix applied.',
    prompt: 'Why is using Write incorrect here?',
    options: [
      'Write is fine for small files',
      'Write replaces the entire file and should only be used for new files. Use the Edit tool for targeted modifications to existing files',
      'Write should be used with a backup flag',
      'The developer should use Bash with sed instead'
    ],
    correct_index: 1,
    explanation: 'Write replaces entire file contents and is for new files only. Edit makes targeted, precision changes to existing files without risking unintended modifications to other lines. Bash with sed is also wrong — Edit is the dedicated tool.'
  },
  {
    id: 'fb-22', domain: 'prompt_engineering',
    scenario: 'You are building a customer review classifier that handles sarcasm, mixed sentiment, and ambiguous language. A teammate proposes adding 12 few-shot examples to cover every edge case.',
    prompt: 'What is the optimal number of few-shot examples?',
    options: [
      '12 examples is fine — more always improves accuracy',
      '2-4 examples is optimal. Include one clear positive, one negative, one mixed, and one edge case like sarcasm. More than 6 bloats the prompt without improving quality',
      'Use only 1 example to establish the format',
      'Few-shot examples are unnecessary — use tool_use with an enum instead'
    ],
    correct_index: 1,
    explanation: '2-4 few-shot examples is the sweet spot. Fewer than 2 doesn\'t establish a pattern; more than 6 adds token cost without quality gains. Each should be diverse and include at least one edge case.'
  },
  {
    id: 'fb-23', domain: 'context_management',
    scenario: 'Your agent is mid-investigation of a production incident. The context window is nearly full. You need to compact, but you\'ve discovered specific file paths, error patterns, and a root cause hypothesis you can\'t afford to lose.',
    prompt: 'How should you preserve critical findings before compacting?',
    options: [
      'Copy findings into the system prompt',
      'Write findings to a scratchpad file (e.g., progress.md) before compacting. Scratchpad files persist on the filesystem across context resets. After compaction, re-read the file to restore context',
      'Start a new session and verbally summarize findings',
      'Rely on compaction to preserve the most important information automatically'
    ],
    correct_index: 1,
    explanation: 'Scratchpad files persist on the filesystem across context resets and session boundaries. After compacting, the agent re-reads the file to restore understanding. Compaction may lose specific details like file paths and error patterns.'
  },
  {
    id: 'fb-24', domain: 'prompt_engineering',
    scenario: 'Your document extraction tool uses a document_type enum: ["invoice", "receipt", "purchase_order"]. In production, 5% of documents are credit notes, which don\'t match any enum value. The extraction fails silently.',
    prompt: 'How should you design the enum to handle unexpected types?',
    options: [
      'Add every possible document type to the enum',
      'Include an "other" category in the enum plus a document_type_detail text field for the model to specify the actual type',
      'Remove the enum and use a free-text field',
      'Add a pre-processing classifier that rejects unsupported types'
    ],
    correct_index: 1,
    explanation: 'Including "other" in enums with a detail field handles unexpected values while maintaining schema structure. Option A can\'t anticipate every type. Option C loses constrained output benefits. Option D rejects potentially valuable documents.'
  },
  {
    id: 'fb-25', domain: 'context_management',
    scenario: 'Two subagents provide conflicting revenue data. The web search agent found "$50M" from a news article summary. The document analysis agent extracted "$47.3M" directly from the company\'s annual report PDF.',
    prompt: 'How should the coordinator resolve this conflict?',
    options: [
      'Average the two values and report $48.65M',
      'Use provenance metadata: the document extraction (from a primary source) outranks the web search (from a secondary summary). Select $47.3M and log the conflict for audit',
      'Report both values and let the user decide',
      'Discard both since they conflict'
    ],
    correct_index: 1,
    explanation: 'Provenance-based conflict resolution ranks by confidence: verified > extracted > inferred > estimated. The annual report extraction is a primary source with higher confidence than a news summary. Option A produces a meaningless average. Option C pushes decisions unnecessarily. Option D discards valid data.'
  },
  // ── Anti-pattern questions ──
  {
    id: 'fb-ap-1', domain: 'agentic_architecture',
    scenario: 'Your team builds a customer support agent that must never process refunds over $500 without manager approval. A senior engineer proposes adding this rule to the system prompt: "CRITICAL: You must NEVER process refunds exceeding $500 without explicit manager approval." In testing, the agent follows the rule 97% of the time.',
    prompt: 'Why is 97% compliance unacceptable, and what is the correct enforcement mechanism?',
    options: [
      '97% is acceptable for most production systems — add monitoring to catch the 3% failures',
      'Prompt-based enforcement is probabilistic and will fail. Use a programmatic PreToolUse hook that intercepts the process_refund tool call, checks the amount, and blocks execution when it exceeds $500 — hooks provide 100% deterministic enforcement',
      'Add more emphasis with ALL CAPS and repeated instructions to increase compliance above 99%',
      'Implement a PostToolUse hook that reverses refunds over $500 after they are processed'
    ],
    correct_index: 1,
    explanation: 'ANTI-PATTERN: Prompt-based enforcement for critical business rules. Prompts are probabilistic — the model CAN and WILL sometimes ignore instructions. For rules with financial consequences, 97% is not enough. Programmatic hooks run as code, not suggestions, providing 100% reliable enforcement. Option A accepts financial risk. Option C doesn\'t guarantee compliance. Option D catches violations after damage is done.'
  },
  {
    id: 'fb-ap-2', domain: 'prompt_engineering',
    scenario: 'Your team switched from prompt-based JSON output to tool_use with a JSON schema, and syntax errors dropped to zero. However, 8% of extractions contain incorrect values — dates are wrong, amounts are transposed, or fields reference the wrong entity.',
    prompt: 'What anti-pattern does this reveal about relying solely on tool_use?',
    options: [
      'The JSON schema needs more constraints to catch value-level errors',
      'Assuming tool_use guarantees semantic correctness is an anti-pattern. tool_use guarantees STRUCTURE only — valid JSON with correct types. Values may still be wrong. Add business rule validation after tool_use to check semantic correctness',
      'The model needs more context about the source document',
      'Switch back to prompt-based output and add a validation step'
    ],
    correct_index: 1,
    explanation: 'ANTI-PATTERN: Assuming tool_use guarantees semantic correctness. Tool use guarantees structure (valid JSON, correct types) but NOT that values are correct. Schema compliance + semantic validation together ensure both correct format AND correct content.'
  },
  {
    id: 'fb-ap-3', domain: 'context_management',
    scenario: 'Your customer support agent maintains context through progressive summarization — every 10 turns, it summarizes the conversation and uses that summary going forward. A customer calls about a $847.50 refund discussed 25 turns ago. The agent responds with $850, having lost the precise figure through two rounds of summarization.',
    prompt: 'What anti-pattern caused the incorrect amount?',
    options: [
      'The summarization interval should be reduced to every 5 turns',
      'Progressive summarization of critical customer details is an anti-pattern — each round loses specifics like amounts, IDs, and dates. Use immutable "case facts" blocks at the start of context that are never summarized',
      'The agent should store all amounts in an external database',
      'Use lossless compression instead of summarization'
    ],
    correct_index: 1,
    explanation: 'ANTI-PATTERN: Progressive summarization of critical details. Each summarization round loses specifics. Immutable "case facts" blocks at the start of context are never summarized and sit in a high-recall position, preserving exact values throughout the conversation.'
  },
  {
    id: 'fb-ap-4', domain: 'claude_code_config',
    scenario: 'Your CI/CD pipeline uses Claude Code to both generate code fixes and review them in the same session. The pipeline runs: claude -p "Fix the failing test, then review your fix for any issues." The review step consistently reports "the fix looks correct" even when human reviewers later find subtle bugs.',
    prompt: 'What anti-pattern explains the ineffective self-review?',
    options: [
      'The review prompt needs more specific criteria',
      'Same-session self-review creates confirmation bias — the reviewer retains the generator\'s reasoning context and is predisposed to approve its own work. Use separate sessions for generation and review',
      'The model needs extended thinking enabled for the review step',
      'Add a third step where the agent re-reviews its review'
    ],
    correct_index: 1,
    explanation: 'ANTI-PATTERN: Same-session self-review. The reviewer shares the generator\'s context, creating confirmation bias. A fresh session reviews the code objectively with no preconceptions. Option A adds specificity but doesn\'t fix bias. Option C adds reasoning depth within the same biased context. Option D compounds the bias.'
  },
  {
    id: 'fb-ap-5', domain: 'agentic_architecture',
    scenario: 'Your customer support agent uses sentiment analysis to decide when to escalate to a human. When negative sentiment exceeds 0.8, the agent transfers the customer. Angry customers with simple issues (like a tracking link) get escalated unnecessarily, while polite customers with complex problems (disputed charges requiring policy exceptions) are handled autonomously and incorrectly.',
    prompt: 'What anti-pattern is causing this misalignment?',
    options: [
      'The sentiment threshold of 0.8 is too low — increase it to 0.95',
      'Sentiment-based escalation confuses emotional tone with task complexity. Escalate based on objective criteria: policy gaps, capability limits, explicit requests, or business thresholds',
      'The agent needs access to more customer history to interpret sentiment',
      'Add a secondary check that verifies the issue can\'t be resolved before escalating'
    ],
    correct_index: 1,
    explanation: 'ANTI-PATTERN: Sentiment-based escalation. An angry customer with a simple request does NOT need a human — they need a fast answer. A polite customer asking for something outside policy DOES need a human. Sentiment does not equal task complexity. Use objective criteria instead.'
  },
];

// ── Seeded PRNG (mulberry32) ──

function mulberry32(seed) {
  return function () {
    seed |= 0; seed = seed + 0x6D2B79F5 | 0;
    var t = Math.imul(seed ^ seed >>> 15, 1 | seed);
    t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
    return ((t ^ t >>> 14) >>> 0) / 4294967296;
  };
}

// ── Daily selection ──

function getDailySeed() {
  return Math.floor(new Date().getTime() / 86400000);
}

function shuffle(arr, rng) {
  var a = arr.slice();
  for (var i = a.length - 1; i > 0; i--) {
    var j = Math.floor(rng() * (i + 1));
    var tmp = a[i]; a[i] = a[j]; a[j] = tmp;
  }
  return a;
}

function selectDailyQuestions(allQuestions, seed) {
  var rng = mulberry32(seed);
  var shuffled = shuffle(allQuestions, rng);
  return shuffled.slice(0, Math.min(DAILY_COUNT, shuffled.length));
}

// ── DOM helper (mirrors main app pattern) ──

function el(tag, attrs, children) {
  var node = document.createElement(tag);
  if (attrs) Object.keys(attrs).forEach(function (k) {
    if (k === 'onclick') node.onclick = attrs[k];
    else if (k === 'className') node.className = attrs[k];
    else if (k === 'style') node.setAttribute('style', attrs[k]);
    else if (k === 'disabled') node.disabled = attrs[k];
    else node.setAttribute(k, attrs[k]);
  });
  if (typeof children === 'string') node.textContent = children;
  else if (Array.isArray(children)) children.forEach(function (c) { if (c) node.appendChild(c); });
  return node;
}

// ── Data layer ──

async function fetchQuestionPool(supabase) {
  var { data: quiz } = await supabase
    .from('quizzes')
    .select('id')
    .eq('slug', 'cca-daily-pool')
    .eq('published', true)
    .single();

  if (!quiz) return { quizId: null, questions: [] };

  var { data: questions } = await supabase
    .from('quiz_questions')
    .select('id, domain, scenario, prompt, options, correct_index, explanation')
    .eq('quiz_id', quiz.id)
    .order('position');

  return { quizId: quiz.id, questions: questions || [] };
}

async function fetchTodayAttempts(supabase, memberId, quizId) {
  var today = new Date().toISOString().slice(0, 10);
  var { data } = await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('member_id', memberId)
    .eq('quiz_id', quizId)
    .gte('completed_at', today + 'T00:00:00')
    .lt('completed_at', today + 'T23:59:59.999')
    .order('score', { ascending: false });

  return data || [];
}

async function fetchRecentAttempts(supabase, memberId, quizId) {
  var since = new Date();
  since.setDate(since.getDate() - HISTORY_DAYS);
  var { data } = await supabase
    .from('quiz_attempts')
    .select('score, total, completed_at')
    .eq('member_id', memberId)
    .eq('quiz_id', quizId)
    .gte('completed_at', since.toISOString())
    .order('completed_at', { ascending: false });

  return data || [];
}

async function saveAttempt(supabase, memberId, quizId, answers, score, total) {
  return supabase.from('quiz_attempts').insert({
    member_id: memberId,
    quiz_id: quizId,
    score: score,
    total: total,
    answers: answers,
  });
}

// ── State ──

function createState() {
  return {
    view: 'loading',       // loading | landing | quiz | results | review
    quizId: null,
    allQuestions: [],
    questions: [],          // today's selected questions
    currentIndex: 0,
    answers: [],            // {question_id, selected_index, correct_index, domain, correct}
    answered: false,        // has current question been answered
    todayBest: null,        // best attempt today
    recentAttempts: [],
  };
}

// ── Views ──

function renderLoading(rootEl) {
  rootEl.replaceChildren(
    el('div', { className: 'quiz-empty' }, 'Loading daily quiz...')
  );
}

function renderEmpty(rootEl, message) {
  rootEl.replaceChildren(
    el('div', { className: 'quiz-empty' }, message || 'No quiz questions available yet. Check back soon.')
  );
}

function renderLanding(rootEl, state, actions) {
  var today = new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'short', day: 'numeric' });

  // Domain tags for today's questions
  var domainCounts = {};
  state.questions.forEach(function (q) {
    domainCounts[q.domain] = (domainCounts[q.domain] || 0) + 1;
  });

  var tags = Object.keys(DOMAINS).map(function (key) {
    var active = domainCounts[key] ? ' quiz-domain-tag--active' : '';
    var label = DOMAINS[key].label;
    if (domainCounts[key]) label += ' (' + domainCounts[key] + ')';
    return el('span', { className: 'quiz-domain-tag' + active }, label);
  });

  var children = [
    el('div', { className: 'quiz-header' }, [
      el('h3', { className: 'quiz-title' }, 'Daily Quiz'),
      el('span', { className: 'quiz-date' }, today),
    ]),
    el('div', { className: 'quiz-domain-tags' }, tags),
  ];

  // Score summary if already taken today
  if (state.todayBest) {
    var pct = Math.round((state.todayBest.score / state.todayBest.total) * 100);
    children.push(
      el('div', { className: 'quiz-score-summary' }, [
        el('p', { className: 'quiz-score-big' }, state.todayBest.score + ' / ' + state.todayBest.total),
        el('p', { className: 'quiz-score-label' }, 'Today\'s best — ' + pct + '%'),
      ]),
      el('div', { className: 'quiz-btn-row' }, [
        el('button', { className: 'quiz-retake-btn', onclick: actions.start }, 'Retake'),
        el('button', { className: 'quiz-review-btn', onclick: function () { actions.reviewFromLanding(state.todayBest); } }, 'Review Answers'),
      ])
    );
  } else {
    children.push(
      el('button', { className: 'quiz-start-btn', onclick: actions.start }, 'Start Quiz (' + state.questions.length + ' questions)')
    );
  }

  // Previous results
  if (state.recentAttempts.length > 0) {
    var items = state.recentAttempts.map(function (a) {
      var d = new Date(a.completed_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
      return el('li', { className: 'quiz-history-item' }, [
        el('span', null, d),
        el('span', null, a.score + ' / ' + a.total),
      ]);
    });

    var details = document.createElement('details');
    details.className = 'quiz-history';
    var summary = document.createElement('summary');
    summary.textContent = 'Previous Results';
    details.appendChild(summary);
    details.appendChild(el('ul', { className: 'quiz-history-list' }, items));
    children.push(details);
  }

  rootEl.replaceChildren(el('div', { className: 'quiz-landing' }, children));
}

function renderQuiz(rootEl, state, actions) {
  var q = state.questions[state.currentIndex];
  var progress = (state.currentIndex + 1) + ' of ' + state.questions.length;
  var pct = ((state.currentIndex + 1) / state.questions.length * 100).toFixed(0);

  var optionEls = q.options.map(function (text, i) {
    var cls = 'quiz-option';
    if (state.answered) {
      cls += ' quiz-option--disabled';
      if (i === q.correct_index) cls += ' quiz-option--correct';
      else if (i === state.answers[state.currentIndex].selected_index && i !== q.correct_index) cls += ' quiz-option--incorrect';
    }

    return el('button', {
      className: cls,
      onclick: state.answered ? null : function () { actions.answer(i); },
      disabled: state.answered,
    }, [
      el('span', { className: 'quiz-option-letter' }, LETTERS[i]),
      el('span', { className: 'quiz-option-text' }, text),
    ]);
  });

  var children = [
    el('div', { className: 'quiz-progress' }, [
      el('span', { className: 'quiz-progress-label' }, 'Question ' + progress),
      el('div', { className: 'quiz-progress-track' }, [
        el('div', { className: 'quiz-progress-bar', style: 'width:' + pct + '%' }),
      ]),
    ]),
    el('span', { className: 'quiz-question-domain' }, DOMAINS[q.domain] ? DOMAINS[q.domain].label : q.domain),
    el('div', { className: 'quiz-scenario' }, q.scenario),
    el('p', { className: 'quiz-prompt' }, q.prompt),
    el('div', { className: 'quiz-options' }, optionEls),
  ];

  if (state.answered) {
    if (q.explanation) {
      children.push(el('div', { className: 'quiz-explanation' }, q.explanation));
    }
    var isLast = state.currentIndex >= state.questions.length - 1;
    children.push(
      el('button', {
        className: 'quiz-next-btn',
        onclick: isLast ? actions.finish : actions.next,
      }, isLast ? 'See Results' : 'Next Question')
    );
  }

  rootEl.replaceChildren(el('div', { className: 'quiz-active' }, children));
}

function renderResults(rootEl, state, actions) {
  var score = state.answers.filter(function (a) { return a.correct; }).length;
  var total = state.answers.length;
  var pct = Math.round((score / total) * 100);
  var pass = pct >= PASS_THRESHOLD * 100;

  // Domain breakdown
  var domainScores = {};
  state.answers.forEach(function (a) {
    if (!domainScores[a.domain]) domainScores[a.domain] = { correct: 0, total: 0 };
    domainScores[a.domain].total++;
    if (a.correct) domainScores[a.domain].correct++;
  });

  var domainRows = Object.keys(domainScores).map(function (key) {
    var d = domainScores[key];
    var dpct = Math.round((d.correct / d.total) * 100);
    var barClass = dpct >= 70 ? 'quiz-domain-bar-fill--good' : dpct >= 40 ? 'quiz-domain-bar-fill--ok' : 'quiz-domain-bar-fill--bad';
    return el('div', { className: 'quiz-domain-row' }, [
      el('span', { className: 'quiz-domain-name' }, DOMAINS[key] ? DOMAINS[key].label : key),
      el('div', { className: 'quiz-domain-bar-track' }, [
        el('div', { className: 'quiz-domain-bar-fill ' + barClass, style: 'width:' + dpct + '%' }),
      ]),
      el('span', { className: 'quiz-domain-score' }, d.correct + '/' + d.total),
    ]);
  });

  rootEl.replaceChildren(
    el('div', { className: 'quiz-results' }, [
      el('h3', { className: 'quiz-results-header' }, 'Quiz Complete'),
      el('div', { className: 'quiz-score-display' }, [
        el('p', { className: 'quiz-score-number' }, score + ' / ' + total),
        el('p', { className: 'quiz-score-percent' + (pass ? ' quiz-score-percent--pass' : ' quiz-score-percent--fail') },
          pct + '% — ' + (pass ? 'Passing' : 'Keep studying')),
      ]),
      el('div', { className: 'quiz-domain-breakdown' }, [
        el('p', { className: 'quiz-domain-breakdown-title' }, 'By Domain'),
      ].concat(domainRows)),
      el('div', { className: 'quiz-btn-row' }, [
        el('button', { className: 'quiz-retake-btn', onclick: actions.start }, 'Retake'),
        el('button', { className: 'quiz-review-btn', onclick: actions.review }, 'Review Answers'),
        el('button', { className: 'quiz-back-btn', onclick: actions.home }, 'Back'),
      ]),
    ])
  );
}

function renderReview(rootEl, state, actions) {
  var items = state.questions.map(function (q, i) {
    var a = state.answers[i];
    if (!a) return null;

    var optionEls = q.options.map(function (text, oi) {
      var cls = 'quiz-option quiz-option--disabled';
      if (oi === q.correct_index) cls += ' quiz-option--correct';
      else if (oi === a.selected_index && oi !== q.correct_index) cls += ' quiz-option--incorrect';
      return el('div', { className: cls }, [
        el('span', { className: 'quiz-option-letter' }, LETTERS[oi]),
        el('span', { className: 'quiz-option-text' }, text),
      ]);
    });

    var children = [
      el('div', { className: 'quiz-review-number' }, 'Question ' + (i + 1) + ' — ' + (DOMAINS[q.domain] ? DOMAINS[q.domain].label : q.domain)),
      el('div', { className: 'quiz-scenario' }, q.scenario),
      el('p', { className: 'quiz-prompt' }, q.prompt),
      el('div', { className: 'quiz-options' }, optionEls),
    ];
    if (q.explanation) {
      children.push(el('div', { className: 'quiz-explanation' }, q.explanation));
    }
    return el('div', { className: 'quiz-review-item' }, children);
  }).filter(Boolean);

  rootEl.replaceChildren(
    el('div', { className: 'quiz-review' }, [
      el('h3', { className: 'quiz-review-header' }, 'Answer Review'),
    ].concat(items).concat([
      el('button', { className: 'quiz-back-btn', onclick: actions.home, style: 'margin-top:16px' }, 'Back to Quiz Home'),
    ]))
  );
}

// ── Entry point ──

export async function mount(rootEl, ctx) {
  var state = createState();
  var supabase = ctx.supabase;
  var memberId = ctx.memberId;

  // Actions object — closures over state & rootEl
  var actions = {
    start: function () {
      state.currentIndex = 0;
      state.answers = [];
      state.answered = false;
      state.view = 'quiz';
      renderQuiz(rootEl, state, actions);
    },

    answer: function (selectedIndex) {
      var q = state.questions[state.currentIndex];
      var correct = selectedIndex === q.correct_index;
      state.answers[state.currentIndex] = {
        question_id: q.id,
        selected_index: selectedIndex,
        correct_index: q.correct_index,
        domain: q.domain,
        correct: correct,
      };
      state.answered = true;
      renderQuiz(rootEl, state, actions);
    },

    next: function () {
      state.currentIndex++;
      state.answered = false;
      renderQuiz(rootEl, state, actions);
    },

    finish: async function () {
      var score = state.answers.filter(function (a) { return a.correct; }).length;
      var total = state.answers.length;
      state.view = 'results';
      renderResults(rootEl, state, actions);

      // Save attempt and fire streak
      if (supabase && memberId && state.quizId) {
        try {
          await saveAttempt(supabase, memberId, state.quizId, state.answers, score, total);
          await ctx.onActivity('quiz');
        } catch (e) {
          // Non-blocking — don't interrupt the results view
        }
      }
    },

    review: function () {
      state.view = 'review';
      renderReview(rootEl, state, actions);
    },

    reviewFromLanding: function (attempt) {
      // Reconstruct answers from the saved attempt for review
      if (attempt && attempt.answers) {
        state.answers = attempt.answers;
      }
      state.view = 'review';
      renderReview(rootEl, state, actions);
    },

    home: async function () {
      // Refresh today's attempts
      if (supabase && memberId && state.quizId) {
        try {
          var todayAttempts = await fetchTodayAttempts(supabase, memberId, state.quizId);
          state.todayBest = todayAttempts.length > 0 ? todayAttempts[0] : null;
          var recent = await fetchRecentAttempts(supabase, memberId, state.quizId);
          state.recentAttempts = recent;
        } catch (e) { /* use existing state */ }
      }
      state.view = 'landing';
      renderLanding(rootEl, state, actions);
    },
  };

  // ── Bootstrap ──

  renderLoading(rootEl);

  var useDb = false;

  // Try loading from Supabase first
  if (supabase) {
    try {
      var pool = await fetchQuestionPool(supabase);
      if (pool.questions.length > 0) {
        state.quizId = pool.quizId;
        state.allQuestions = pool.questions;
        useDb = true;
      }
    } catch (e) { /* fall through to fallback */ }
  }

  // Fallback to hardcoded questions if DB is empty or unavailable
  if (!useDb) {
    state.quizId = 'local';
    state.allQuestions = FALLBACK_QUESTIONS;
  }

  // Select today's questions
  var seed = getDailySeed();
  state.questions = selectDailyQuestions(state.allQuestions, seed);

  // Check for existing attempts today (only works with DB)
  if (useDb && memberId && state.quizId) {
    try {
      var todayAttempts = await fetchTodayAttempts(supabase, memberId, state.quizId);
      state.todayBest = todayAttempts.length > 0 ? todayAttempts[0] : null;
      state.recentAttempts = await fetchRecentAttempts(supabase, memberId, state.quizId);
    } catch (e) { /* proceed without history */ }
  }

  state.view = 'landing';
  renderLanding(rootEl, state, actions);
}
