-- ============================================================================
-- CCA-F Daily Quiz — Seed Data
-- Owner: Allie (@allierays)
--
-- Run this in the Supabase SQL editor AFTER creating the tables and RLS
-- policies from docs/superpowers/plans/2026-04-16-quizzes-schema.md
--
-- Creates one pool quiz + 50 questions across 5 CCA-F domains.
-- All questions follow the official exam style: scenario → question → 4 options.
-- ============================================================================

-- Step 1: Create the pool quiz
INSERT INTO quizzes (slug, title, description, question_count, published)
VALUES (
  'cca-daily-pool',
  'CCA-F Daily Practice',
  'Daily practice questions covering all 5 Claude Certified Architect exam domains. 5 questions served each day, rotated deterministically.',
  50,
  true
);

-- Step 2: Insert questions
-- Domain distribution matches exam weights:
--   agentic_architecture:  14 questions (27%)
--   tool_design_mcp:        9 questions (18%)
--   claude_code_config:     10 questions (20%)
--   prompt_engineering:     10 questions (20%)
--   context_management:      7 questions (15%)

-- ============================================================================
-- DOMAIN: agentic_architecture (14 questions)
-- ============================================================================

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  1,
  'agentic_architecture',
  'You are building an agentic loop that processes customer refund requests. The agent has access to tools for looking up orders, verifying eligibility, and issuing refunds. In production, you notice the agent occasionally processes refunds for orders that have already been refunded, because it skips the eligibility check tool and calls the refund tool directly.',
  'What change would most effectively prevent duplicate refunds?',
  '["Add a strongly worded instruction to the system prompt stating that the agent must always verify eligibility before processing any refund", "Implement a programmatic prerequisite in your agentic loop that blocks the refund tool until the eligibility check tool has returned a verified status", "Add few-shot examples showing the agent always calling the eligibility check before the refund tool", "Deploy a separate validation agent that reviews each refund decision before it is executed"]'::jsonb,
  1,
  'When a specific tool sequence is required for critical business logic, programmatic enforcement provides deterministic guarantees. Options A and C rely on probabilistic LLM compliance, which is insufficient when errors have financial consequences. Option D is over-engineered — a simple prerequisite check in the loop is the proportionate fix.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  2,
  'agentic_architecture',
  'Your agentic loop processes the API response and checks stop_reason to determine whether to continue iterating. During testing, you observe that the agent sometimes stops prematurely after a tool call, even though the task is not complete. The stop_reason in these cases is "end_turn".',
  'What is the most likely root cause of the premature termination?',
  '["The agent is hitting the max_tokens limit, which is being misreported as end_turn", "The tool results are not being properly formatted as tool_result content blocks, so the model interprets the conversation as complete", "The system prompt does not explicitly instruct the agent to continue working after receiving tool results", "The agentic loop is checking for end_turn but not handling the pause_turn stop reason correctly"]'::jsonb,
  1,
  'When tool results are not formatted correctly as tool_result blocks in the conversation, the model lacks the context that a tool was executed and may treat the turn as complete. Option A is incorrect because max_tokens produces its own distinct stop_reason. Option C addresses a symptom, not root cause — properly formatted tool results are what keep the loop going. Option D is about a different stop_reason that applies to server-executed tools.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  3,
  'agentic_architecture',
  'You are designing a multi-agent system where a coordinator agent delegates research tasks to three specialized subagents: a web search agent, a document analysis agent, and a data extraction agent. During testing, you notice the coordinator sends overly broad task descriptions to the subagents, leading to irrelevant results and wasted tokens.',
  'Which approach most effectively improves the quality of task delegation?',
  '["Give each subagent access to all tools so they can self-correct when they receive broad instructions", "Add detailed task decomposition instructions to the coordinator''s system prompt with examples of good vs. bad delegation", "Implement a validation layer between the coordinator and subagents that checks task descriptions against a schema before forwarding", "Replace the coordinator with a deterministic routing function that maps user queries to predefined subagent task templates"]'::jsonb,
  1,
  'The coordinator''s task decomposition is the root issue. Adding explicit instructions with examples of good vs. bad delegation directly addresses the quality of its output. Option A gives subagents more tools but doesn''t fix the coordinator''s poor instructions. Option C adds infrastructure without fixing the source of bad instructions. Option D removes the flexibility that makes a coordinator valuable and over-constrains the system.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  4,
  'agentic_architecture',
  'Your multi-agent system has a coordinator that spawns subagents for different tasks. A web search subagent times out while researching a complex topic. You need to design how this failure information flows back to the coordinator so it can make intelligent recovery decisions.',
  'Which error propagation approach best enables the coordinator to recover?',
  '["Return structured error context including the failure type, attempted query, any partial results, and suggested alternative approaches", "Implement automatic retry logic with exponential backoff within the subagent, returning a generic ''search unavailable'' status only after all retries are exhausted", "Catch the timeout within the subagent and return an empty result set marked as successful to avoid disrupting the coordinator", "Propagate the raw timeout exception directly to a top-level error handler that logs the failure and terminates the workflow"]'::jsonb,
  0,
  'Structured error context gives the coordinator the information it needs to make intelligent recovery decisions — whether to retry with a modified query, try an alternative approach, or proceed with partial results. Option B hides valuable context behind a generic status. Option C suppresses the error entirely, risking incomplete outputs. Option D terminates the workflow unnecessarily when recovery strategies could succeed.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  5,
  'agentic_architecture',
  'You are building a customer support agent that handles account changes including email updates, password resets, and account deletions. Account deletions are irreversible and affect billing. Your team wants the agent to handle all three operations autonomously to minimize support queue wait times.',
  'What is the most appropriate architecture for handling account deletions?',
  '["Allow the agent to process all operations autonomously since the user explicitly requested the deletion", "Implement a human-in-the-loop checkpoint that pauses the agent and requires a support manager to approve account deletions before execution", "Add a 24-hour cooling-off period where the deletion is queued and automatically executed if the user does not cancel", "Have the agent confirm the deletion request three times with the user before processing to ensure intent"]'::jsonb,
  1,
  'Human-in-the-loop is the correct pattern for irreversible, high-stakes actions with billing impact. The agent should pause and escalate rather than act autonomously. Option A ignores the irreversibility risk. Option C delays but doesn''t add human oversight for a consequential action. Option D adds friction without human judgment — the agent is still acting autonomously and multiple confirmations don''t substitute for human review.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  6,
  'agentic_architecture',
  'Your agent uses the Claude Agent SDK and needs to enforce a compliance requirement: all customer data retrieved during a session must be redacted from the final response. You are deciding between implementing this as a prompt instruction vs. a PostToolUse hook.',
  'When should you use a programmatic hook rather than a prompt instruction for enforcement?',
  '["When the requirement is a best practice that should be followed most of the time but has acceptable exceptions", "When the requirement is a hard compliance rule where any violation has legal or regulatory consequences", "When the requirement applies only to a specific subset of tools and would clutter the system prompt", "When the model already demonstrates strong adherence to the requirement through training"]'::jsonb,
  1,
  'Hard compliance rules with legal consequences require deterministic enforcement that prompt instructions cannot guarantee. Hooks provide programmatic guarantees regardless of model behavior. Option A describes a case where prompt instructions are acceptable. Option C is about prompt organization, not enforcement reliability. Option D suggests the requirement doesn''t need enforcement at all, which is dangerous for compliance.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  7,
  'agentic_architecture',
  'You are designing a document processing pipeline that needs to handle 500 documents. Each document requires extraction, validation, and summarization. You are deciding between processing all documents in a single long-running agent session vs. splitting into multiple independent sessions.',
  'What is the primary risk of processing all 500 documents in a single agent session?',
  '["The API will reject requests that exceed a maximum session duration limit", "Context accumulation across 500 documents will degrade extraction quality as the context window fills, leading to missed fields and errors in later documents", "The agent will run out of tool calls, as there is a hard limit on tool invocations per session", "Processing costs will be significantly higher in a single session because each document adds to the input token count of subsequent requests"]'::jsonb,
  1,
  'As the context window fills with results from processed documents, attention dilution causes quality degradation — the model loses accuracy on later documents. This is the practical concern with long-running sessions. Option A is incorrect; there is no session duration limit. Option C is incorrect; there is no hard tool call limit. Option D describes a real cost concern but is not the primary risk — quality degradation is more critical than cost.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  8,
  'agentic_architecture',
  'Your agent needs to complete a complex codebase refactoring that will exceed the context window. You want to ensure continuity across multiple context windows so work is not repeated and state is preserved.',
  'Which approach most effectively maintains state across context windows?',
  '["Save all conversation history to a file and reload it at the start of each new context window", "Use git commits as checkpoints and write structured handoff files (like a tests.json and init.sh) that capture the current state and remaining tasks", "Rely on the compaction feature to automatically summarize and carry forward all relevant context", "Store intermediate results in environment variables that persist across sessions"]'::jsonb,
  1,
  'Git checkpoints plus structured handoff files (tests, scripts, task lists) create durable, verifiable state that new context windows can discover from the filesystem. Option A would quickly exceed the context window again. Option C is for within-session management, not cross-session continuity. Option D is unreliable — environment variables don''t persist across separate agent invocations.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  9,
  'agentic_architecture',
  'You are using the Claude Agent SDK to build a research agent. During testing on Claude Opus 4.6, you notice the agent spawns subagents excessively — even for simple tasks that could be handled directly. This increases latency and cost without improving output quality.',
  'What is the most effective way to reduce unnecessary subagent spawning?',
  '["Switch to a different model that spawns fewer subagents by default", "Add explicit guidance to the system prompt about when to use subagents vs. working directly, with examples of tasks that do and don''t warrant delegation", "Remove the subagent spawning capability entirely and handle all tasks in a single agent", "Implement a token budget limit that prevents subagent creation when costs exceed a threshold"]'::jsonb,
  1,
  'Claude Opus 4.6 has a known predilection for excessive subagent spawning, but it is steerable through prompting. Explicit guidance with examples of when to delegate vs. work directly addresses the root behavior. Option A avoids the model rather than fixing the configuration. Option C removes a valuable capability entirely. Option D addresses cost after the fact rather than preventing unnecessary spawning.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  10,
  'agentic_architecture',
  'Your agentic loop receives a response with stop_reason: "pause_turn". Your current loop only handles "end_turn" and "tool_use" stop reasons, treating everything else as a termination signal.',
  'What does pause_turn indicate and how should it be handled?',
  '["The model has been rate-limited and the loop should wait before retrying the same request", "The server-side tool iteration limit was hit and the model is not finished — re-send the conversation to continue processing", "The model detected unsafe content and paused for human review before continuing", "The context window is nearly full and the model is signaling that compaction should be triggered"]'::jsonb,
  1,
  'pause_turn means the server-side iteration limit was reached for server-executed tools, but the model isn''t finished. The correct handling is to re-send the conversation to let the model continue. Option A confuses this with rate limiting, which produces HTTP 429 errors. Option C describes a content moderation scenario that uses a different mechanism. Option D confuses this with context window management.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  11,
  'agentic_architecture',
  'You are building a workflow where an agent first gathers requirements, then generates a technical design, then implements code. Each phase depends on the previous phase''s output. You are deciding between prompt chaining (three separate, sequential calls) and a single agentic loop with tools.',
  'When is prompt chaining preferred over a single agentic loop?',
  '["When each phase requires a different model or different parameters (temperature, max_tokens) optimized for that specific task", "When the total token count across all phases would exceed the context window in a single session", "When you need real-time streaming of intermediate results to the user", "When the workflow must be completed as quickly as possible with minimum latency"]'::jsonb,
  0,
  'Prompt chaining excels when each phase has different requirements — different models, temperatures, or output constraints. It gives you explicit control over transitions between phases. Option B could also be addressed by compaction within a single loop. Option C can be achieved with streaming in either pattern. Option D actually favors fewer API calls (agentic loop), not more (chaining).'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  12,
  'agentic_architecture',
  'Your coordinator agent delegates a data analysis task to a subagent. The subagent needs access to a database query tool but should not have access to the email-sending tool that the coordinator uses for notifications. Currently, both agents share the same tool set.',
  'Which approach most effectively limits the subagent''s tool access?',
  '["Add instructions to the subagent''s system prompt that it should only use the database query tool and ignore the email tool", "Scope the subagent''s tool list at invocation time to include only the database query tool, excluding the email tool entirely", "Create a wrapper around the email tool that checks the calling agent''s identity and rejects calls from the subagent", "Give the subagent access to all tools but set tool_choice to force it to use only the database query tool"]'::jsonb,
  1,
  'Scoping tools at invocation time applies the principle of least privilege — the subagent literally cannot see or call the email tool. Option A relies on prompt compliance, which is probabilistic. Option C adds unnecessary complexity when you can simply not provide the tool. Option D forces a specific tool on every call, preventing the subagent from using any tool naturally.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  13,
  'agentic_architecture',
  'Your multi-agent research system processes user queries by having the coordinator decompose them into subtasks. After deploying to production with the query "impact of AI on creative industries," the final report only covers visual arts (digital art, graphic design, photography), completely missing music, writing, and film. The subagents all completed their assigned tasks successfully.',
  'What is the most likely root cause of the incomplete coverage?',
  '["The web search subagent''s queries were not comprehensive enough to find results about non-visual creative industries", "The coordinator''s task decomposition was too narrow, producing subtask assignments that only covered visual arts domains", "The document analysis subagent filtered out sources about non-visual industries due to overly restrictive relevance criteria", "The synthesis agent failed to identify coverage gaps in the combined findings from all subagents"]'::jsonb,
  1,
  'The subagents executed their assigned tasks correctly — the problem is what they were assigned. The coordinator decomposed "creative industries" into only visual arts subtasks, which is a task decomposition failure. Options A, C, and D incorrectly blame downstream agents that are working correctly within their assigned scope.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  14,
  'agentic_architecture',
  'You need to resume a previously interrupted Claude Code session that was working on a complex refactoring. The session had made progress on several files before being interrupted. You want to pick up exactly where it left off.',
  'What is the correct way to resume an interrupted session in Claude Code?',
  '["Start a new session and paste the conversation history from the previous session into the first message", "Use the --resume flag to continue the previous session with its full conversation context intact", "Create a new session and manually describe what was done previously so Claude can continue", "Use fork_session to create a branch of the interrupted session and continue from there"]'::jsonb,
  1,
  'The --resume flag is the built-in mechanism for continuing interrupted sessions with full context. Option A would be impractical and lose tool call context. Option C loses precision about what was done. Option D (fork_session) creates a branch for parallel work, not for resuming a single interrupted session.'
);

-- ============================================================================
-- DOMAIN: tool_design_mcp (9 questions)
-- ============================================================================

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  15,
  'tool_design_mcp',
  'Your agent has two tools: get_customer (retrieves customer information) and lookup_order (retrieves order details). Production logs show the agent frequently calls get_customer when users ask about orders (e.g., "check my order #12345"). Both tools have minimal descriptions: "Retrieves customer information" and "Retrieves order details."',
  'What is the most effective first step to improve tool selection accuracy?',
  '["Add few-shot examples to the system prompt demonstrating correct tool selection with 5-8 examples", "Expand each tool''s description to include input formats, example queries, boundaries, and when to use it versus similar tools", "Implement a routing layer that parses user input and pre-selects the appropriate tool based on keyword matching", "Consolidate both tools into a single lookup_entity tool that internally routes to the correct backend"]'::jsonb,
  1,
  'Tool descriptions are by far the most important factor in tool selection. When descriptions are minimal, the model lacks context to differentiate between similar tools. Expanding descriptions is a low-effort, high-leverage fix. Option A adds token overhead without fixing the underlying issue. Option C bypasses the LLM''s natural language understanding. Option D is valid but more effort than a first step warrants.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  16,
  'tool_design_mcp',
  'You are designing a set of tools for an agent that manages GitHub repositories. You have created 15 individual tools: create_issue, update_issue, close_issue, list_issues, create_pr, update_pr, merge_pr, list_prs, add_label, remove_label, create_branch, delete_branch, list_branches, add_reviewer, remove_reviewer.',
  'How should you restructure these tools for better agent performance?',
  '["Keep all 15 tools since they each serve a distinct function and naming makes their purpose clear", "Consolidate related operations into fewer tools with an action parameter — e.g., github_issues(action: ''create'' | ''update'' | ''close'' | ''list'') — reducing the total tool count", "Group tools into categories using a prefix convention like issue_create, issue_update, pr_create, pr_update", "Remove rarely-used tools and only expose the 5 most common operations to reduce cognitive load on the model"]'::jsonb,
  1,
  'Consolidating related operations into fewer tools with an action parameter follows official best practices. Too many tools increases the chance of incorrect selection. Option A ignores the tool selection challenge with 15 options. Option C is just a naming convention that doesn''t reduce count. Option D removes functionality rather than organizing it.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  17,
  'tool_design_mcp',
  'Your MCP tool for querying a database sometimes returns errors. Currently, when a query fails, the tool returns: {"error": "failed"}. The agent retries the same failing query repeatedly without adjusting its approach.',
  'How should you improve the error response to enable better agent recovery?',
  '["Return the raw database error message and stack trace so the agent has full debugging information", "Return a structured error with is_error: true, an error category, whether the error is retryable, and a suggested correction — e.g., {\"is_error\": true, \"message\": \"Column ''user_name'' not found. Available columns: name, email, created_at\", \"isRetryable\": true}", "Implement automatic retry logic inside the tool with exponential backoff so the agent never sees errors", "Return a successful response with an empty result set and a warning field indicating the query had issues"]'::jsonb,
  1,
  'Structured error responses with actionable information enable the agent to correct its approach. Specifying available columns lets the agent fix the query. Option A may include sensitive information and is unstructured. Option C hides errors and prevents the agent from learning. Option D suppresses errors by marking failures as successes, which prevents any correction.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  18,
  'tool_design_mcp',
  'You want to guarantee that Claude''s tool calls always match your schema exactly — no missing required fields, no extra fields, no type mismatches. Your application processes financial data where malformed tool calls could cause incorrect calculations.',
  'Which feature provides this guarantee?',
  '["Setting tool_choice to \"tool\" to force the model to always use the specific tool", "Enabling strict: true on the tool definition, which uses constrained decoding to guarantee schema conformance", "Adding JSON Schema validation to the tool description text so the model understands the requirements", "Implementing client-side validation that rejects and retries malformed tool calls until they conform"]'::jsonb,
  1,
  'strict: true enables constrained decoding, which guarantees tool call outputs match the schema exactly through grammar-level enforcement. Option A forces tool use but doesn''t guarantee the schema of the call. Option C relies on the model reading and following the description, which is probabilistic. Option D catches errors after generation rather than preventing them.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  19,
  'tool_design_mcp',
  'You are using tool_choice to control your agent''s behavior. In one workflow step, you need the agent to use exactly one tool from its available set, but the specific tool should be the model''s decision based on context. You also want to prevent the agent from generating any natural language before the tool call.',
  'Which tool_choice setting achieves this?',
  '["tool_choice: \"auto\" — the default that lets Claude decide whether and which tool to use", "tool_choice: \"any\" — forces the model to use one of the provided tools and prefills the response to prevent text before the tool call", "tool_choice: {\"type\": \"tool\", \"name\": \"specific_tool\"} — forces the model to use one specific named tool", "tool_choice: \"none\" — prevents tool use so the model can only respond with text"]'::jsonb,
  1,
  'tool_choice: "any" forces the model to call one of the available tools and prevents natural language text before the tool_use block. Option A allows the model to skip tool use entirely. Option C forces a specific tool rather than letting the model choose. Option D prevents all tool use.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  20,
  'tool_design_mcp',
  'You have enabled extended thinking on your Claude request and are also providing tools. You set tool_choice to "any" to force tool use. The API returns an error.',
  'What is the most likely cause of this error?',
  '["Extended thinking requires a minimum budget_tokens value that was not set", "The tool_choice values \"any\" and \"tool\" are not supported when extended thinking is enabled", "Extended thinking and tool use cannot be used together in the same request", "The tools array exceeds the maximum of 20 tools allowed with extended thinking"]'::jsonb,
  1,
  'tool_choice values "any" and "tool" are explicitly not supported with extended thinking — this is a documented incompatibility that produces an error. Option A is about a deprecated parameter. Option C is incorrect — tool use and thinking work together, just not with forced tool_choice. Option D describes the strict tool limit, not a thinking-related restriction.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  21,
  'tool_design_mcp',
  'Your tool returns large result payloads — full database records with 50+ fields — even though the agent typically only needs 3-4 fields for its next decision. This is consuming significant context window space and increasing costs.',
  'What is the recommended approach to optimize tool responses?',
  '["Implement pagination so the agent can request specific pages of results", "Design tool responses to return only high-signal information — semantic identifiers and the specific fields needed for the agent''s next step, not full records", "Compress the tool response payload using a more compact encoding format", "Cache tool results server-side so repeated calls don''t consume additional context"]'::jsonb,
  1,
  'Official best practice is to return only high-signal information from tools — semantic/stable identifiers and fields needed for the next step. This directly reduces context consumption. Option A addresses quantity of records but not fields per record. Option C doesn''t reduce semantic content. Option D prevents re-fetching but doesn''t address the initial payload size.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  22,
  'tool_design_mcp',
  'You are configuring an MCP server to provide tools to your Claude Code setup. The server exposes a database query tool that should only be available when working with files in the src/database/ directory of your project.',
  'Where should you configure this conditional tool availability?',
  '["In the project''s CLAUDE.md file, adding an instruction that the database tool should only be used when working on database files", "In .claude/rules/ with a rule file that has a paths frontmatter field matching src/database/**", "In the MCP server''s configuration, setting a path filter that restricts when the tool is advertised", "In a PreToolUse hook that denies the database tool when the current file is outside src/database/"]'::jsonb,
  3,
  'A PreToolUse hook can programmatically check the context and deny tool calls based on the current working file path. This provides deterministic enforcement. Option A relies on prompt compliance. Option B applies to CLAUDE.md rules loading, not tool availability. Option C assumes MCP servers support path-based tool filtering, which is not a standard MCP feature.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  23,
  'tool_design_mcp',
  'You are writing a tool definition for a complex API integration tool. The tool accepts nested JSON objects with specific format requirements for date fields and enum values. During testing, the agent frequently sends malformed inputs.',
  'What is the most effective way to improve input accuracy for complex tools?',
  '["Add detailed validation error messages that explain exactly what format is expected when the input is malformed", "Add input_examples to the tool definition — an array of example input objects that demonstrate correct usage patterns for complex cases", "Increase the detail in the tool description to include all format requirements inline", "Implement automatic input transformation that coerces common malformed inputs into the correct format"]'::jsonb,
  1,
  'input_examples provide concrete, validated examples that demonstrate correct usage patterns for complex inputs. They are specifically designed for tools with nested objects or format-sensitive inputs. Option A helps after errors but doesn''t prevent them. Option C makes descriptions very long. Option D masks the problem rather than helping the model generate correct inputs.'
);

-- ============================================================================
-- DOMAIN: claude_code_config (10 questions)
-- ============================================================================

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  24,
  'claude_code_config',
  'You want to create a custom /review slash command that runs your team''s standard code review checklist. This command should be available to every developer on the team when they clone or pull the repository.',
  'Where should you place this command file?',
  '["In ~/.claude/commands/ in each developer''s home directory", "In .claude/commands/ in the project repository", "In the CLAUDE.md file at the project root as a section under ''Commands''", "In .claude/config.json with a commands array defining the command"]'::jsonb,
  1,
  'Project-scoped custom slash commands belong in .claude/commands/ within the repository — they are version-controlled and automatically available to all developers who clone or pull. Option A is for personal commands not shared via version control. Option C is for project instructions, not command definitions. Option D describes a configuration mechanism that does not exist.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  25,
  'claude_code_config',
  'Your CLAUDE.md file has grown to 400+ lines containing coding standards, testing conventions, a PR review checklist, deployment instructions, and database migration procedures. You want Claude to always follow coding standards and testing conventions, but only apply PR review, deployment, and migration guidance when performing those specific tasks.',
  'What is the most maintainable approach to organize this content?',
  '["Split everything into separate CLAUDE.md files in subdirectories so each area of the codebase has its own instructions", "Keep coding standards and testing conventions in the root CLAUDE.md, and move PR review, deployment, and migration guidance into separate .claude/rules/ files with paths frontmatter that conditionally loads them based on file patterns", "Create custom slash commands for PR review, deployment, and migration so the guidance is only loaded when the user explicitly invokes those commands", "Keep everything in a single CLAUDE.md but use HTML comments to mark sections that Claude should ignore unless relevant"]'::jsonb,
  2,
  'Moving task-specific content into .claude/rules/ with conditional loading or into custom slash commands keeps always-relevant guidance (coding standards) in CLAUDE.md while loading specialized content only when needed. Option A scatters always-relevant content across directories. Option B uses rules well but paths frontmatter matches file types, not task types — slash commands are better for task-specific guidance. Option D relies on Claude inferring relevance, which is unreliable.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  26,
  'claude_code_config',
  'Your team integrates Claude Code into the CI pipeline for automated code reviews on pull requests. The pipeline script runs: claude "Analyze this pull request for security issues" but the job hangs indefinitely. Logs show Claude Code is waiting for interactive input.',
  'What is the correct fix to run Claude Code in a CI pipeline?',
  '["Set the environment variable CLAUDE_HEADLESS=true before running the command", "Add the -p flag: claude -p \"Analyze this pull request for security issues\"", "Redirect stdin from /dev/null: claude \"Analyze...\" < /dev/null", "Add the --batch flag: claude --batch \"Analyze this pull request for security issues\""]'::jsonb,
  1,
  'The -p (--print) flag runs Claude Code in non-interactive mode — it processes the prompt, outputs to stdout, and exits without waiting for user input. This is the documented approach for CI/CD. Options A, C, and D reference non-existent features or Unix workarounds that don''t properly address Claude Code''s command interface.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  27,
  'claude_code_config',
  'Your codebase has distinct areas with different coding conventions: React components use functional style with hooks, API handlers use async/await with specific error handling, and test files are spread throughout the codebase alongside the code they test (e.g., Button.test.tsx next to Button.tsx). You want Claude to automatically apply the correct conventions based on what file it is working with.',
  'What is the most effective way to configure this?',
  '["Create separate CLAUDE.md files in each subdirectory containing area-specific conventions", "Create .claude/rules/ files with YAML frontmatter specifying glob patterns (e.g., **/*.test.tsx) to conditionally apply conventions based on file paths", "Consolidate all conventions in the root CLAUDE.md under headers for each area, relying on Claude to infer which applies", "Create .claude/skills/ for each code type that include the relevant conventions"]'::jsonb,
  1,
  '.claude/rules/ with glob patterns (e.g., **/*.test.tsx) allows conventions to be automatically applied based on file paths regardless of directory location — essential for test files spread throughout the codebase. Option A can''t handle files spread across many directories. Option C relies on inference rather than explicit matching. Option D requires manual invocation or uncertain automatic loading.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  28,
  'claude_code_config',
  'You have been assigned to restructure a monolithic application into microservices. This involves changes across dozens of files and requires decisions about service boundaries, module dependencies, and API contracts. You need to explore the codebase and understand the current architecture before making changes.',
  'Which Claude Code approach should you use?',
  '["Start in direct execution mode, making changes incrementally and letting the implementation reveal natural service boundaries", "Enter plan mode to explore the codebase, understand dependencies, and design an implementation approach before making any changes", "Use direct execution with comprehensive upfront instructions detailing exactly how each service should be structured", "Begin in direct execution and switch to plan mode only if unexpected complexity emerges during implementation"]'::jsonb,
  1,
  'Plan mode is designed for complex tasks involving large-scale changes, multiple valid approaches, and architectural decisions — exactly what a monolith-to-microservices restructuring requires. It enables safe exploration before committing to changes. Option A risks costly rework when dependencies surface late. Option C assumes you already know the right structure. Option D ignores that the complexity is already known from the requirements.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  29,
  'claude_code_config',
  'You want to create a deployment skill that should only be invoked by the user explicitly typing /deploy — it should never be triggered automatically by Claude during a conversation, even if deployment seems relevant to the task at hand.',
  'Which SKILL.md frontmatter configuration achieves this?',
  '["Set user-invocable: true and add a description warning Claude not to invoke it automatically", "Set disable-model-invocation: true to prevent Claude from invoking the skill autonomously while still allowing user invocation via /deploy", "Set context: fork to isolate the skill from the main conversation", "Remove the description field so Claude cannot discover the skill''s purpose"]'::jsonb,
  1,
  'disable-model-invocation: true is the specific frontmatter field that prevents Claude from invoking a skill autonomously while preserving user access via the slash command. Option A uses a description-based approach which is probabilistic. Option C isolates execution context but doesn''t prevent invocation. Option D might hide the skill''s purpose but doesn''t prevent invocation if Claude encounters it.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  30,
  'claude_code_config',
  'Your organization wants to enforce a mandatory CLAUDE.md policy across all developer machines — for example, requiring that all generated code includes copyright headers. Individual developers should not be able to exclude or override this policy.',
  'Where should this managed policy file be placed?',
  '["In each project''s root CLAUDE.md file, maintained by the DevOps team", "In /Library/Application Support/ClaudeCode/CLAUDE.md on macOS (or /etc/claude-code/CLAUDE.md on Linux) — the managed policy location that cannot be excluded", "In ~/.claude/CLAUDE.md in each developer''s home directory, with file permissions set to read-only", "In a .claude/rules/ file at the project level with a mandatory: true frontmatter flag"]'::jsonb,
  1,
  'The managed policy location (/Library/Application Support/ClaudeCode/CLAUDE.md on macOS, /etc/claude-code/CLAUDE.md on Linux) is specifically designed for organization-wide policies that cannot be excluded by individual developers. Option A can be modified per-project. Option C can be modified by the developer. Option D uses a frontmatter flag that doesn''t exist.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  31,
  'claude_code_config',
  'You want Claude Code to automatically run your linter after every file edit, without requiring the user to approve each linter execution. The linter should run transparently and provide feedback if issues are found.',
  'Which hook configuration achieves this?',
  '["A PostToolUse hook on the Write tool that runs the linter command and returns the output as feedback", "A PreToolUse hook on the Write tool that runs the linter before the write is committed", "A SessionStart hook that configures a file watcher to run the linter on changes", "A custom slash command that the user can invoke to run the linter after editing"]'::jsonb,
  0,
  'A PostToolUse hook on the Write tool runs automatically after each file edit, executing the linter and feeding results back. This is transparent and requires no user action. Option B runs before the write, so it would lint the old file content. Option C uses a file watcher which is external to Claude''s workflow. Option D requires manual invocation, not automatic execution.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  32,
  'claude_code_config',
  'You are running Claude Code in a CI pipeline and want the output as structured JSON so your pipeline can parse the results programmatically. You also want to limit the agent to a maximum of 5 tool-use turns to prevent runaway execution.',
  'Which combination of flags achieves this?',
  '["claude -p \"...\" --output-format json --max-turns 5", "claude -p \"...\" --json --max-iterations 5", "claude -p \"...\" --format json --tool-limit 5", "claude -p \"...\" --output-format json --timeout 300"]'::jsonb,
  0,
  '--output-format json produces structured JSON output and --max-turns limits the number of agentic turns. Both are valid flags that work with -p (print mode). Option B uses non-existent flags. Option C uses non-existent flags. Option D uses a timeout (time-based) rather than a turn limit.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  33,
  'claude_code_config',
  'Your project has the following CLAUDE.md files: a root ./CLAUDE.md with coding standards, a ./CLAUDE.local.md with your personal API keys for testing, a ~/.claude/CLAUDE.md with your global preferences, and a ./src/api/CLAUDE.md with API-specific conventions.',
  'In what order are these files loaded and when does the subdirectory file apply?',
  '["All four files are loaded at startup in order: managed policy → project root → user → local. The src/api/CLAUDE.md loads only when Claude reads or edits files in that directory.", "Files override each other in priority order, with CLAUDE.local.md taking highest priority and overriding all other settings.", "All files are loaded at startup and concatenated. Subdirectory files are always included regardless of what files Claude works with.", "Only the root CLAUDE.md and CLAUDE.local.md are loaded. User and subdirectory files require explicit @imports."]'::jsonb,
  0,
  'CLAUDE.md files are discovered by walking up the directory tree and are concatenated (not overriding). CLAUDE.local.md is appended after CLAUDE.md at each level. Subdirectory CLAUDE.md files load on demand when Claude accesses files in that directory. Option B is wrong — files concatenate, not override. Option C is wrong about subdirectory loading. Option D is wrong about user-level files.'
);

-- ============================================================================
-- DOMAIN: prompt_engineering (10 questions)
-- ============================================================================

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  34,
  'prompt_engineering',
  'You are building a document processing pipeline that extracts structured data from legal contracts. The output must conform to a strict JSON schema with specific field types and required fields. Any deviation from the schema causes downstream processing failures.',
  'Which approach guarantees schema conformance in the output?',
  '["Add the JSON schema to the system prompt and instruct Claude to follow it exactly", "Use output_config with format type json_schema and provide the full schema definition for constrained decoding", "Provide 3-5 few-shot examples of correct JSON output in the prompt", "Implement client-side JSON validation that retries until the output matches the schema"]'::jsonb,
  1,
  'output_config with json_schema type provides guaranteed schema conformance through constrained decoding — the output literally cannot deviate from the schema. Option A relies on instruction following, which is probabilistic. Option C helps but doesn''t guarantee conformance. Option D catches errors but adds latency from retries and doesn''t prevent malformed outputs.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  35,
  'prompt_engineering',
  'Your team wants to reduce API costs for two Claude-powered workflows: (1) a blocking pre-merge code review check that must complete before developers can merge PRs, and (2) a weekly technical debt report generated Sunday night for Monday morning review. Your manager proposes switching both to the Message Batches API for its 50% cost savings.',
  'How should you evaluate this proposal?',
  '["Switch both workflows to batch processing — the 50% savings applies to all usage and most batches complete quickly", "Use batch processing for the technical debt reports only; keep real-time API calls for pre-merge checks", "Keep real-time calls for both — batch processing introduces ordering issues that could affect code review accuracy", "Switch both to batch processing with a fallback to real-time if the batch takes longer than 30 minutes"]'::jsonb,
  1,
  'The Batch API offers 50% savings but has processing times up to 24 hours with no guaranteed latency. This makes it unsuitable for blocking pre-merge checks where developers wait, but ideal for overnight/weekly reports. Option A ignores that blocking workflows can''t tolerate variable latency. Option C incorrectly claims ordering issues — batch results use custom_id for correlation. Option D adds complexity when the simpler solution is matching each API to its use case.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  36,
  'prompt_engineering',
  'You are processing a long document (80,000 tokens) with a query asking Claude to extract specific data points. You notice that extraction accuracy is significantly worse for information in the middle of the document compared to the beginning and end.',
  'What is the most effective way to improve extraction accuracy across the entire document?',
  '["Increase max_tokens to give Claude more space to process the full document", "Restructure the request to place the document content at the top and the extraction query at the end of the prompt", "Split the document into smaller chunks and process each independently", "Enable extended thinking so Claude can reason more carefully about the middle sections"]'::jsonb,
  1,
  'Placing documents above queries/instructions improves quality by up to 30% for long-context processing. This addresses the ''lost in the middle'' effect by ensuring the query comes after all content has been processed. Option A doesn''t affect input processing quality. Option C loses cross-reference context. Option D doesn''t specifically address positional attention patterns.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  37,
  'prompt_engineering',
  'You are implementing prompt caching for a chatbot that has a large system prompt (8,000 tokens) and maintains conversation history. You want to maximize cache hit rates to reduce costs. The system prompt is identical across all requests, and conversation history grows with each turn.',
  'Where should you place the cache_control breakpoint for optimal caching?',
  '["On the first message in the conversation history, since it''s the oldest and most stable content", "On the system prompt, since it''s identical across all requests and changes at the top of the hierarchy invalidate all subsequent caches", "On the last user message, since it''s the most recent content that will be reused", "On each individual message in the conversation history to cache as much as possible"]'::jsonb,
  1,
  'The system prompt is the most stable content and sits at the top of the cache hierarchy. Caching it ensures every request reuses those 8,000 tokens at 90% savings. Changes at any level invalidate that level and all subsequent content, so caching the stable system prompt maximizes hit rates. Option A caches conversation history which grows and shifts. Option C caches the most volatile content. Option D wastes cache slots on changing content.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  38,
  'prompt_engineering',
  'You want Claude to classify customer support tickets into categories. Your initial prompt says: "Don''t assign multiple categories. Don''t use categories not in the list. Don''t leave the category field empty." Claude occasionally violates these constraints.',
  'How should you restructure the prompt to improve compliance?',
  '["Add more emphasis by capitalizing the constraints: ''NEVER assign multiple categories''", "Reframe as positive instructions: ''Assign exactly one category from the provided list for every ticket. The category field must always contain a value.''", "Add a penalty clause: ''If you violate these rules, the output will be rejected''", "Move the constraints to the end of the prompt where they will be processed last"]'::jsonb,
  1,
  'Telling Claude what to DO instead of what NOT to do is an official prompting best practice. Positive framing (''assign exactly one'') is clearer and more reliably followed than negative constraints (''don''t assign multiple''). Option A adds emphasis but keeps the negative framing. Option C adds consequences the model can''t meaningfully process. Option D is about positioning, not framing.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  39,
  'prompt_engineering',
  'You are building a classification system and want Claude to reason through its decision before providing a final answer. You are using Claude Opus 4.6 with extended thinking enabled and want to control the depth of reasoning based on task complexity.',
  'Which parameter controls the depth of Claude''s extended thinking?',
  '["Set budget_tokens to allocate a specific number of tokens for the thinking process", "Use the effort parameter with values like ''low'', ''medium'', ''high'', or ''max'' to control thinking depth adaptively", "Set temperature to a lower value to make the model''s reasoning more focused and deterministic", "Add ''Think step by step'' to the prompt to encourage deeper reasoning"]'::jsonb,
  1,
  'The effort parameter (low, medium, high, xhigh, max) controls adaptive thinking depth — Claude dynamically decides how much to think based on this setting. Option A (budget_tokens) is deprecated in favor of the effort parameter. Option C affects sampling randomness, not reasoning depth. Option D is a prompting technique that doesn''t control the extended thinking feature.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  40,
  'prompt_engineering',
  'You need to submit 50,000 document classification requests. Each request is independent, and results are needed within 24 hours for a weekly report. The standard API cost would be $2,000.',
  'Which approach is most cost-effective for this workload?',
  '["Send all requests through the standard Messages API with concurrent connections to maximize throughput", "Use the Message Batches API — it supports up to 100,000 requests per batch, provides 50% cost savings, and has a 24-hour processing window that fits your timeline", "Process requests sequentially with prompt caching enabled to reuse the classification prompt across all 50,000 requests", "Split into 5 batches of 10,000 and process each batch on a different day to spread the cost"]'::jsonb,
  1,
  'The Batch API is specifically designed for this use case: large volumes of independent requests with flexible timing. 50% cost savings ($1,000 vs $2,000) with a 24-hour window that matches the timeline. Option A costs full price. Option C helps with caching but doesn''t provide the 50% batch discount. Option D spreads the work unnecessarily when the batch API handles it in one submission.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  41,
  'prompt_engineering',
  'You are building a data extraction pipeline and want Claude to output results as validated JSON matching a Pydantic model in Python. You want the validation to happen automatically without manual parsing.',
  'Which SDK method provides automatic Pydantic model validation of Claude''s output?',
  '["client.messages.create() with a JSON schema in the system prompt", "client.messages.parse() with a Pydantic model class, which validates and deserializes the response automatically", "client.messages.create() with output_config.format.type set to ''json'' and manual Pydantic validation after", "client.messages.stream() with a custom JSON parser that validates against the Pydantic model"]'::jsonb,
  1,
  'client.messages.parse() is the SDK method specifically designed for automatic Pydantic model validation. It combines constrained output generation with automatic deserialization into Pydantic objects. Option A requires manual parsing. Option C requires manual validation. Option D requires custom implementation of something the SDK provides natively.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  42,
  'prompt_engineering',
  'You are prompting Claude to analyze financial reports. When extended thinking is disabled on Claude Opus 4.5, you notice that using the phrase "think carefully about" in your prompt sometimes causes inconsistent behavior — the model seems to attempt internal reasoning that degrades output quality.',
  'What is the recommended approach to handle this?',
  '["Enable extended thinking so the model can properly reason through the analysis", "Replace ''think carefully'' with alternative phrasing like ''consider'' or ''evaluate'' — Claude Opus 4.5 is sensitive to the word ''think'' when thinking is disabled", "Remove all reasoning instructions and let the model decide how to approach the analysis", "Add explicit chain-of-thought steps to guide the model''s reasoning process"]'::jsonb,
  1,
  'Claude Opus 4.5 has a documented sensitivity to the word "think" when extended thinking is disabled — it can trigger inconsistent internal reasoning. Using alternative words like "consider" or "evaluate" avoids this. Option A changes the feature rather than the prompt. Option C removes helpful guidance. Option D adds structure but still might use the triggering word.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  43,
  'prompt_engineering',
  'You have a long system prompt with tool definitions, followed by conversation history. You want to add prompt caching. The cache invalidation hierarchy is: tools → system → messages. You''ve added cache_control to your system prompt.',
  'What happens if you modify a tool definition between requests?',
  '["Only the tool cache is invalidated; the system prompt and message caches remain valid", "The tool-level change invalidates the tool cache AND the system prompt cache AND the message cache — changes at any level invalidate that level and all subsequent levels", "Tool definitions are not part of the cache hierarchy and can be modified without affecting caches", "The cache is completely rebuilt from scratch, ignoring all previous cache entries"]'::jsonb,
  1,
  'The cache invalidation hierarchy works top-down: tools → system → messages. A change at the tool level (the top) invalidates tools AND all subsequent levels (system prompt and messages). This is why stable content should be placed higher in the hierarchy. Option A misunderstands the cascading invalidation. Option C is factually wrong. Option D overstates the impact — only content after the change point is invalidated.'
);

-- ============================================================================
-- DOMAIN: context_management (7 questions)
-- ============================================================================

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  44,
  'context_management',
  'Your agent is in a long-running session that has accumulated 140,000 tokens of conversation history. You have compaction configured with the default trigger threshold. The model is Claude Opus 4.6 with a 1M token context window.',
  'At what point will compaction be triggered, and what happens when it fires?',
  '["Compaction triggers at 140,000 tokens (current level) and removes all messages, starting a fresh context", "Compaction triggers at the default threshold of 150,000 tokens — it creates a compaction block summarizing the conversation, and all message blocks prior to it are dropped on subsequent requests", "Compaction triggers when the context window is 50% full (500,000 tokens) to maintain a safety buffer", "Compaction triggers continuously, summarizing every 10,000 tokens of new content to keep the context lean"]'::jsonb,
  1,
  'The default compaction trigger is 150,000 tokens (minimum configurable: 50,000). When triggered, it creates a compaction block containing a conversation summary, and the API automatically drops all prior message blocks on subsequent requests. Option A is premature and destructive. Option C uses the wrong threshold. Option D describes continuous summarization, not how compaction works.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  45,
  'context_management',
  'Your agent uses extended thinking during multi-turn conversations with tool use. After a tool call cycle completes, you notice that the conversation history has grown significantly due to thinking blocks from previous turns.',
  'How should thinking blocks be managed across turns to optimize context usage?',
  '["Keep all thinking blocks in the conversation history to maintain full reasoning context", "Thinking blocks from previous turns are automatically stripped by the API — they are not carried forward as input. However, during an active tool use cycle, the thinking block accompanying the tool request MUST be included with the tool result.", "Remove all thinking blocks after each turn to minimize context usage", "Thinking blocks should be summarized and included as a system message for the next turn"]'::jsonb,
  1,
  'The API automatically strips thinking blocks between turns — they don''t carry forward as input. The critical exception: during tool use, the thinking block that accompanies a tool request must remain paired with its tool result (verified by cryptographic signatures). Option A wastes context on blocks that are stripped anyway. Option C is too aggressive — removing during tool use would break the flow. Option D adds unnecessary complexity.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  46,
  'context_management',
  'A pull request modifies 14 files across a stock tracking module. Your single-pass automated review produces inconsistent results: detailed feedback for some files but superficial comments for others, and contradictory feedback — flagging a pattern as problematic in one file while approving identical code elsewhere.',
  'How should you restructure the review to address this inconsistency?',
  '["Switch to a model with a larger context window to give all 14 files adequate attention in one pass", "Split into focused passes: analyze each file individually for local issues, then run a separate integration pass examining cross-file data flow", "Require developers to split large PRs into smaller submissions of 3-4 files before automated review runs", "Run three independent review passes on the full PR and only flag issues that appear in at least two passes"]'::jsonb,
  1,
  'Splitting reviews into focused passes directly addresses attention dilution — the root cause when processing many files at once. File-by-file analysis ensures consistent depth, while a separate integration pass catches cross-file issues. Option A misunderstands that larger windows don''t solve attention quality. Option C shifts burden to developers. Option D would suppress detection of real bugs by requiring consensus.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  47,
  'context_management',
  'You are using Claude Sonnet 4.6 in an agent that makes many tool calls. After each tool call, you notice the model receives system messages like "<system_warning>Token usage: 35000/1000000; 965000 remaining</system_warning>". Your agent doesn''t currently use this information.',
  'How can you leverage this context awareness feature?',
  '["Ignore it — context awareness is for internal model use only and shouldn''t affect your application logic", "Use it to implement intelligent context management: the agent can proactively summarize or offload information when remaining budget drops below a threshold, preventing quality degradation from context rot", "Parse the token counts to calculate API costs in real-time for billing purposes", "Use it to determine when to switch to a smaller, cheaper model mid-conversation"]'::jsonb,
  1,
  'Context awareness lets the model (and your application) make intelligent decisions about context management before hitting limits. Proactive summarization or offloading when budget gets low prevents the quality degradation that comes with full context windows. Option A wastes valuable information. Option C conflates token counts with costs (pricing varies by cache status). Option D introduces model-switching complexity.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  48,
  'context_management',
  'You are sending a request to Claude with a system prompt (5,000 tokens), tool definitions (3,000 tokens), conversation history (180,000 tokens), and expecting an output of up to 4,000 tokens. The model has a 200,000 token context window.',
  'What will happen when you send this request?',
  '["The request will succeed but the output will be silently truncated to fit within the remaining context", "Claude will process the full input and attempt to generate the output, potentially with degraded quality at the end", "The API will return a validation error because the combined input and output tokens would exceed the context window", "The request will succeed but the oldest messages in the conversation history will be automatically dropped to make room"]'::jsonb,
  2,
  'Newer Claude models (Sonnet 3.7+) return a validation error when prompt + output tokens exceed the context window, instead of silently truncating. Total = 5,000 + 3,000 + 180,000 + 4,000 = 192,000, which could exceed the window after accounting for overhead. Option A describes old model behavior. Option B ignores the validation check. Option D describes automatic truncation that doesn''t happen.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  49,
  'context_management',
  'You have compaction enabled with pause_after_compaction: true. Your agent is in the middle of a critical multi-step workflow when compaction triggers. You want to ensure that the most recent tool results and instructions are not lost in the summary.',
  'What does pause_after_compaction: true give you?',
  '["It pauses the agent entirely and requires manual approval to continue", "It gives you control to inspect the compaction summary and optionally preserve critical recent exchanges before the prior messages are dropped", "It delays compaction until the current tool call cycle completes", "It creates a backup of the full conversation before compaction so you can restore it if needed"]'::jsonb,
  1,
  'pause_after_compaction: true gives you the opportunity to review the compaction block and preserve critical recent context. You can re-add important messages or modify the summary before the next request drops prior content. Option A overstates the pause mechanism. Option C delays rather than providing control. Option D describes a backup mechanism that doesn''t exist.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  50,
  'context_management',
  'You want to estimate token usage before sending a request to Claude to ensure it will fit within the context window. You have a large document to process and need to decide whether to split it.',
  'What is the recommended way to estimate token count before sending?',
  '["Count words and multiply by 1.3 as a rough approximation of token count", "Use the token counting API to get an accurate estimate of the input token count before sending the full request", "Send the request with a low max_tokens value first to see how many input tokens are reported in the usage field", "Use a third-party tokenizer library calibrated to Claude''s tokenization algorithm"]'::jsonb,
  1,
  'Anthropic provides a dedicated token counting API that gives accurate estimates before sending the full request. This lets you make informed decisions about splitting or trimming without wasting API calls. Option A is inaccurate. Option C wastes a full API call and costs. Option D may not match Claude''s exact tokenization.'
);

-- ============================================================================
-- ADDITIONAL QUESTIONS (sourced from community practice tests)
-- ============================================================================

-- ── Agentic Architecture (additional) ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  51,
  'agentic_architecture',
  'Your customer support agent processes billing disputes by calling tools like lookup_order, get_invoice, and process_refund. A code review reveals that after each tool call, your loop checks whether Claude''s response text contains the phrase "I have completed" to decide whether to stop iterating.',
  'What is the primary problem with this loop termination approach?',
  '["The agent will never terminate because process_refund always returns a success message that prevents ''I have completed'' from appearing", "Relying on natural language signals in the assistant''s text is unreliable; the correct approach is to inspect stop_reason and only terminate when it equals end_turn", "The loop should terminate as soon as any tool call fails, since continuing after a failure will corrupt the conversation history", "Checking response text is only valid in synchronous mode; you must use a callback handler for proper loop control in async contexts"]'::jsonb,
  1,
  'Inspecting stop_reason is the canonical method for agentic loop control. Parsing natural language (''I have completed'') is unreliable — the model may phrase completion differently or include similar phrases mid-task. Option A describes a specific tool behavior that isn''t the general problem. Option C is wrong; tool failures don''t necessarily mean the loop should stop. Option D invents a distinction that doesn''t exist.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  52,
  'agentic_architecture',
  'Your coordinator agent always routes every query through all four subagents regardless of complexity. For a simple factual question like "What year was the Anthropic API released?" the system takes 45 seconds and consumes significant tokens across all subagents.',
  'What design change most directly addresses this inefficiency?',
  '["Build a static routing table mapping keywords to predefined pipelines", "Let each subagent self-select into or out of the pipeline based on the query", "Have the coordinator dynamically select which subagents to invoke based on query complexity and type", "Reduce to two subagents by merging related capabilities"]'::jsonb,
  2,
  'The coordinator should dynamically assess complexity and route accordingly — simple factual queries may only need the web search agent, while complex research needs all subagents. Option A is brittle and can''t handle novel queries. Option B removes the coordinator''s role in orchestration. Option D reduces capability permanently rather than routing intelligently.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  53,
  'agentic_architecture',
  'Your document analysis agent discovers that two credible sources contain directly contradictory statistics: a government report states 40% growth while an industry analysis states 12%. Both sources are credible, and the discrepancy could materially affect the research conclusions.',
  'How should the document analysis agent handle this contradiction most effectively?',
  '["Apply heuristics to determine which source is more reliable and report only that figure", "Include both figures without marking any conflict to avoid biasing the synthesis", "Immediately escalate to the coordinator without completing its analysis", "Complete its analysis including both figures, annotate the conflict with source details, and flag it for the coordinator to reconcile"]'::jsonb,
  3,
  'The agent should complete its work while preserving the conflict for the coordinator to resolve with broader context. Option A makes a judgment call outside the agent''s scope. Option B hides a critical discrepancy. Option C abandons work prematurely — the coordinator needs the agent''s full findings to make an informed decision.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  54,
  'agentic_architecture',
  'Your customer support agent handles simple requests (3-4 tool calls) with 91% success, but complex multi-issue requests (12+ tool calls) drop to 54% success. Customers frequently contact with multiple issues: a billing dispute, a missing order, and an email update — all in one conversation.',
  'What change most effectively improves complex request handling?',
  '["Add explicit verification checkpoints between each tool call", "Reduce the number of available tools by combining related operations", "Decompose multi-issue requests into separate items, then investigate each in parallel using shared customer context", "Add few-shot examples showing ideal tool-call sequences for complex requests"]'::jsonb,
  2,
  'Decomposing multi-issue requests into independent items with shared context mirrors how the exam tests multi-agent coordination. Each issue can be resolved independently while the customer context is shared. Option A adds overhead without addressing the root cause. Option B reduces capability. Option D helps but doesn''t structurally address the complexity problem.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  55,
  'agentic_architecture',
  'You need to investigate a production incident across an unknown number of files and services. The root cause appears to be a bug introduced in the past two weeks. You don''t know in advance which files are relevant or how many steps the investigation will take.',
  'Which task decomposition strategy is most appropriate?',
  '["Define fixed investigation steps upfront: check logs, review recent commits, run tests", "Use dynamic adaptive decomposition — generate prioritized subtasks based on discovered information, adjusting the investigation as new evidence emerges", "Split between two agents that independently investigate and report to a human", "Run a comprehensive codebase search first, producing a ranked list of suspicious files"]'::jsonb,
  1,
  'When the scope is unknown upfront, dynamic decomposition lets the agent adapt its investigation based on what it discovers. Fixed steps (A) can''t account for unknown unknowns. Splitting between agents (C) without coordination risks duplicated work. A comprehensive search (D) is one step, not a decomposition strategy.'
);

-- ── Tool Design & MCP (additional) ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  56,
  'tool_design_mcp',
  'Your check_fraud_risk MCP tool returns {"isError": true, "message": "Refund blocked"} when an item is flagged for fraud. The agent retries three times, each retry generating a new fraud alert in the backend system.',
  'What is missing from the error response that would prevent this?',
  '["A retry_after timestamp indicating when to try again", "An isRetryable: false flag and a customer-appropriate explanation distinguishing a business rule block from a transient error", "A return as successful with a blocked: true field instead of an error", "A fraud risk score so the agent can decide whether to retry"]'::jsonb,
  1,
  'The agent retries because it doesn''t know the error is a permanent business rule, not a transient failure. Adding isRetryable: false explicitly tells the agent not to retry, and a clear explanation distinguishes business logic blocks from infrastructure errors. Option A implies it should retry later. Option C hides the error. Option D gives the agent information it shouldn''t act on.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  57,
  'tool_design_mcp',
  'Your web search subagent calls search_web and receives {"results": [], "status": "success"}. Later you discover the search API was actually down during that period — it returned an empty success response instead of an error.',
  'What MCP change prevents this silent failure from misleading the agent?',
  '["Always return non-empty results with fallback content when the actual API fails", "Distinguish access failures from valid empty results by using the isError flag when the upstream API is unreachable", "Add a confidence field to indicate result reliability", "Implement automatic retry with exponential backoff"]'::jsonb,
  1,
  'The root problem is that an API failure is being reported as a successful empty result. Using isError: true for access failures lets the agent distinguish "no results found" from "couldn''t reach the API." Option A masks failures with fake data. Option C adds ambiguity. Option D retries without knowing the API is down.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  58,
  'tool_design_mcp',
  'Your synthesis agent has been given access to all 18 tools in the system, including tools for web search, database queries, and email sending. During testing, you notice the synthesis agent sometimes initiates new web searches instead of synthesizing the findings it already received.',
  'What problem does giving too many tools to a specialized agent introduce?',
  '["The agent refuses to use any tools due to cognitive overload from too many options", "Access to tools outside its specialization increases the likelihood of the agent acting outside its intended role, like searching instead of synthesizing", "18 tools exceed the API''s tool context limit, causing truncation", "Additional tools slow the agent''s response time proportionally"]'::jsonb,
  1,
  'Giving a specialized agent tools outside its role violates the principle of least privilege and invites scope creep — the synthesis agent starts doing research instead of synthesizing. Option A is incorrect; models don''t refuse tools. Option C is wrong; 18 tools are within limits. Option D overstates the performance impact.'
);

-- ── Claude Code Config (additional) ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  59,
  'claude_code_config',
  'Your /analyze-codebase skill produces hundreds of lines of intermediate output while exploring the codebase. After the skill runs, subsequent responses in the conversation are degraded because the exploration output pollutes the context window.',
  'Which SKILL.md frontmatter setting fixes this while maintaining the skill''s capabilities?',
  '["Set allowed-tools: [] to prevent the skill from using any tools", "Set context: fork to run the skill in an isolated subagent so its verbose output doesn''t pollute the main conversation", "Move the skill from .claude/skills/ to .claude/commands/ which has automatic context isolation", "Add argument-hint to skip context inheritance from the main conversation"]'::jsonb,
  1,
  'context: fork runs the skill in an isolated subagent. The skill can still do its full analysis, but the verbose intermediate output stays in the fork — only the final result returns to the main conversation. Option A removes all tool access, breaking the skill. Option C doesn''t provide context isolation. Option D doesn''t exist as described.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  60,
  'claude_code_config',
  'Your team needs to add a shared GitHub MCP server that requires per-developer authentication tokens. The tokens must not be committed to version control, but the MCP server configuration itself should be available to all team members who clone the repository.',
  'Which configuration approach achieves this?',
  '["Each developer adds the MCP server in user scope via claude mcp add --scope user", "Add the MCP server to the project .mcp.json using environment variable substitution (${GITHUB_TOKEN}) so each developer provides their own token via environment variables", "Add the server to the root CLAUDE.md file under an [mcp_servers] section", "Create a setup script that writes the configuration to ~/.claude.json on each machine"]'::jsonb,
  1,
  'Project-scoped .mcp.json with ${GITHUB_TOKEN} environment variable substitution keeps the server configuration shared in version control while each developer provides their own secret via environment variables. Option A requires each developer to manually configure, isn''t shared. Option C is not a valid CLAUDE.md section. Option D adds setup friction and isn''t self-documenting.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  61,
  'claude_code_config',
  'You are adding a single null-check to one function. The scope is clear, the fix is obvious, and there''s no ambiguity about the implementation.',
  'Should you use plan mode or direct execution?',
  '["Plan mode, because even small changes could have side effects that should be analyzed first", "Direct execution, because the task is well-scoped with a clear fix and plan mode would add unnecessary overhead", "Plan mode to generate a comprehensive test plan before making the change", "Direct execution first, then switch to plan mode for a post-change verification scan"]'::jsonb,
  1,
  'Plan mode is designed for complex tasks with multiple approaches and architectural decisions. A single null-check is well-scoped with an obvious fix — direct execution is the proportionate response. Option A over-applies plan mode to trivial changes. Option C adds unnecessary process. Option D creates extra steps for a simple fix.'
);

-- ── Prompt Engineering (additional) ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  62,
  'prompt_engineering',
  'Your extraction pipeline uses a prompt requesting Claude to output JSON wrapped in a code block. In production, 3% of responses have JSON syntax errors — missing quotes, trailing commas, or unclosed brackets — causing downstream parsing failures.',
  'What change most effectively eliminates these syntax errors?',
  '["Add a validation step that retries up to 3 times when JSON parsing fails", "Switch to tool use with a defined JSON schema as the input parameter, which guarantees valid JSON through constrained decoding", "Add an instruction to the prompt telling Claude to double-check its JSON syntax before responding", "Implement a regex post-processor that fixes common JSON syntax errors"]'::jsonb,
  1,
  'Tool use with a defined JSON schema guarantees valid JSON through constrained decoding — syntax errors become impossible. Option A catches errors but doesn''t prevent them and adds latency. Option C is probabilistic. Option D is fragile and can''t handle all malformation patterns.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  63,
  'prompt_engineering',
  'After switching to tool_choice: "auto" for your data extraction pipeline, you notice that Claude returns plain text descriptions 30% of the time instead of calling the extraction tool. The tool is defined correctly and works when invoked.',
  'What change ensures Claude always uses the extraction tool?',
  '["Set tool_choice to \"any\" to guarantee the model invokes one of the provided tools", "Set tool_choice to {\"type\": \"tool\", \"name\": \"extract_data\"} to force the specific extraction tool", "Add a system prompt instruction stating that the tool must always be used", "Merge all extraction schemas into one tool to reduce confusion"]'::jsonb,
  0,
  'tool_choice: "any" forces the model to call one of the available tools, preventing text-only responses. Option B forces a specific tool, which is too rigid if you have multiple valid tools. Option C is probabilistic. Option D is an architectural change that doesn''t address the tool_choice configuration issue.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  64,
  'prompt_engineering',
  'Your invoice extraction system achieves 92% accuracy overall, but 8% of invoices fail business validation: the extracted line item amounts don''t sum to the extracted total_amount. The extraction format itself is correct — it''s the values that are wrong.',
  'What retry approach most effectively fixes these validation failures?',
  '["Retry up to 3 times with the same prompt, hoping for a better extraction", "Append the original document, the failed extraction, and the specific validation error to a follow-up prompt so Claude can see exactly what went wrong and correct it", "Route all validation failures to a human reviewer", "Add a calculated_total field in post-processing that overrides the extracted total"]'::jsonb,
  1,
  'Providing Claude with the failed extraction alongside the specific validation error gives it targeted context to correct the mistake. Option A retries blindly without feedback. Option C doesn''t scale. Option D masks the extraction error rather than fixing it — the line items or total could be wrong.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  65,
  'prompt_engineering',
  'Two Claude iterations have failed to produce the correct API response transformation. The requirements describe the transformation in prose, and Claude''s output is close but consistently mishandles edge cases in the date formatting and nested object structure.',
  'What is the most effective approach to fix this?',
  '["Add JSON schema validation to catch errors automatically", "Provide 2-3 concrete input-output examples showing the exact expected transformation, including the edge cases", "Rewrite the requirements in more technical language with precise specifications", "Ask Claude to explain its understanding of the requirements before attempting the transformation"]'::jsonb,
  1,
  'Few-shot examples with concrete input/output pairs are the most effective way to communicate exact transformation expectations, especially for edge cases that are hard to describe in prose. Option A catches errors but doesn''t prevent them. Option C may still be ambiguous. Option D adds a diagnostic step but doesn''t fix the core issue.'
);

-- ── Context Management (additional) ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  66,
  'context_management',
  'Your synthesis agent needs to process combined research output totaling 155,000 tokens from multiple subagents. Testing shows the synthesis agent performs best when its input is under 50,000 tokens. Simply truncating the output loses critical information.',
  'What is the most effective solution to reduce input size while preserving information quality?',
  '["Have upstream agents return structured key findings with metadata instead of raw verbose output", "Add an intermediate summarization agent between research and synthesis", "Process the synthesis in batches, feeding 50,000 tokens at a time", "Store raw output in a vector database and have the synthesis agent query for relevant sections"]'::jsonb,
  0,
  'Having upstream agents return structured, high-signal data addresses the problem at the source — less data is generated in the first place, and what''s generated is directly useful for synthesis. Option B adds another agent and another summarization step. Option C loses cross-reference ability between batches. Option D adds infrastructure complexity.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  67,
  'context_management',
  'Your synthesis agent is producing a report from multiple sources. Some claims come directly from primary research papers, while others come from summaries of summaries. A downstream compliance system needs to assess the reliability of each claim.',
  'What output structure best supports downstream confidence assessment?',
  '["A flat list of findings with no source attribution", "Provenance metadata with each claim: the direct source, confidence level, and the chain of reasoning from source to claim", "Only include claims that come from primary sources, filtering out secondary sources entirely", "Append all source URLs at the end of the report for downstream systems to verify independently"]'::jsonb,
  1,
  'Provenance metadata enables downstream systems to assess claim reliability based on source directness. Option A provides no basis for confidence assessment. Option C loses valuable information from secondary sources. Option D requires downstream systems to re-analyze all sources rather than using the chain of reasoning already established.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  68,
  'context_management',
  'A developer is reading through a 500-file repository to understand its architecture. After reading about 20 files, the context window fills up and subsequent reads return degraded results with missed details.',
  'What approach most effectively handles large codebase exploration within context limits?',
  '["Switch to a model with a larger context window", "Use targeted queries with Grep and Glob to identify relevant files before reading, rather than reading files sequentially", "Split the repository into chunks and explore each in a separate session", "Generate an architecture diagram from the directory structure first"]'::jsonb,
  1,
  'Targeted queries (Grep for patterns, Glob for file discovery) let you find relevant files efficiently without filling the context with irrelevant content. Option A delays the problem rather than solving it. Option C loses cross-file understanding. Option D gives structure but not code-level understanding.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  69,
  'context_management',
  'You completed a research investigation and identified two potential architectural approaches from the same baseline findings. You want to explore both approaches independently without one exploration''s context contaminating the other.',
  'Which session management approach is most appropriate?',
  '["Start two new sessions and copy-paste the research findings into each", "Use --resume twice to create two parallel sessions from the same point", "Use fork_session to create independent branches from the current session state, then explore each approach in its own fork", "Continue in the same session, using /compact between the two explorations to reset context"]'::jsonb,
  2,
  'fork_session creates independent branches that share the same baseline context but diverge independently — exactly what''s needed for parallel exploration without contamination. Option A loses tool call context and is error-prone. Option B isn''t how --resume works. Option D risks context bleed between explorations despite compaction.'
);

-- ============================================================================
-- ANTI-PATTERN QUESTIONS
-- These test recognition of common mistakes and why they're wrong.
-- Source: https://claudecertifications.com/claude-certified-architect/anti-patterns
-- ============================================================================

-- ── Agentic Architecture anti-patterns ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  70,
  'agentic_architecture',
  'A developer has implemented an agentic loop for a billing agent. To determine when the agent is done, the loop parses Claude''s response text looking for phrases like "I have finished" or "task complete." During load testing, the agent sometimes stops mid-task when it uses similar phrases in its reasoning, and other times loops indefinitely when it phrases completion differently.',
  'What is the fundamental anti-pattern in this design, and what should replace it?',
  '["The phrases are too specific — use a broader set of completion phrases with regex matching", "Parsing natural language for loop control is unreliable because phrasing varies. Replace with checking the stop_reason field, which is a deterministic structured signal (tool_use to continue, end_turn to stop)", "The loop needs a timeout fallback so it terminates after a maximum duration regardless of text content", "The agent should be instructed to always use the exact phrase ''TASK_COMPLETE'' as a structured signal"]'::jsonb,
  1,
  'ANTI-PATTERN: Parsing natural language for loop termination. Text content is for the user, not control flow. The model may phrase completion differently each time, making it unreliable. The stop_reason field is deterministic — tool_use means continue, end_turn means the model is done. Option A makes the regex more complex but doesn''t fix the fundamental problem. Option C adds a safety net but doesn''t fix the core issue. Option D is slightly better but still relies on the model following a text convention.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  71,
  'agentic_architecture',
  'Your team builds a customer support agent that must never process refunds over $500 without manager approval. A senior engineer proposes adding this rule to the system prompt: "CRITICAL: You must NEVER process refunds exceeding $500 without explicit manager approval. This is a hard requirement." In testing, the agent follows the rule 97% of the time.',
  'Why is 97% compliance unacceptable, and what is the correct enforcement mechanism?',
  '["97% is acceptable for most production systems — add monitoring to catch the 3% failures", "Prompt-based enforcement is probabilistic and will fail. Use a programmatic PreToolUse hook that intercepts the process_refund tool call, checks the amount, and blocks execution when it exceeds $500 — hooks provide 100% deterministic enforcement", "Add more emphasis with ALL CAPS and repeated instructions to increase compliance above 99%", "Implement a PostToolUse hook that reverses refunds over $500 after they are processed"]'::jsonb,
  1,
  'ANTI-PATTERN: Prompt-based enforcement for critical business rules. Prompts are probabilistic — the model CAN and WILL sometimes ignore instructions, even critical ones. For rules with financial or legal consequences, 97% is not enough. Programmatic hooks (PreToolUse) run as code, not suggestions, providing 100% reliable enforcement. Option A accepts a 3% failure rate on financial operations. Option C improves odds marginally but doesn''t guarantee compliance. Option D catches violations after damage is done.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  72,
  'agentic_architecture',
  'Your customer support agent uses sentiment analysis to decide when to escalate to a human agent. When negative sentiment exceeds 0.8, the agent transfers the customer. In production, you notice that angry customers with simple, easily-resolved issues (like a tracking link) are being escalated unnecessarily, while polite customers with genuinely complex problems (like disputed charges requiring policy exceptions) are handled autonomously and incorrectly.',
  'What anti-pattern is causing this misalignment?',
  '["The sentiment threshold of 0.8 is too low — increase it to 0.95 to reduce unnecessary escalations", "Sentiment-based escalation confuses emotional tone with task complexity. Escalation should be based on objective criteria: policy gaps, capability limits, explicit customer requests, or business thresholds like refund amounts", "The agent needs access to more customer history to better interpret sentiment signals", "Add a secondary check that verifies the customer''s issue can''t be resolved before escalating"]'::jsonb,
  1,
  'ANTI-PATTERN: Sentiment-based escalation. An angry customer with a simple request does NOT need a human — they need a fast answer. A polite customer asking for something outside policy DOES need a human. Sentiment does not equal task complexity. Escalation should use objective criteria: policy gaps, capability limits, explicit requests, or business thresholds. Option A adjusts the wrong lever. Option C adds data without fixing the wrong signal. Option D partially helps but still uses sentiment as the primary trigger.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  73,
  'agentic_architecture',
  'Your agent has a self-evaluation step where it rates its own confidence on a scale of 1-10 before each response. Responses with confidence below 6 are automatically escalated to a human reviewer. In production, the agent reports confidence of 8-9 on cases it gets wrong, and confidence of 5-6 on cases it handles correctly but that seem subjectively harder.',
  'What anti-pattern does this illustrate?',
  '["The confidence threshold of 6 is poorly calibrated — adjust it based on historical accuracy data", "Self-reported confidence scores from LLMs are poorly calibrated and unreliable for production decisions. The agent is confidently wrong and uncertainly right. Replace with programmatic checks based on observable facts like policy coverage and data completeness", "The agent needs more training data to improve its confidence calibration", "Add a validation layer that independently verifies the agent''s confidence before accepting it"]'::jsonb,
  1,
  'ANTI-PATTERN: Self-reported confidence scores for decision-making. Model confidence is not well-calibrated — models can be highly confident when wrong and uncertain when right. Production decisions should be based on programmatic checks using observable facts (does the policy cover this case? Is the data complete?) rather than the model''s self-assessment. Option A tries to calibrate an inherently unreliable signal. Option C assumes calibration can be improved through data. Option D adds a check but still relies on the original flawed signal.'
);

-- ── Tool Design & MCP anti-patterns ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  74,
  'tool_design_mcp',
  'Your agent has access to 18 tools for managing a full customer lifecycle: account creation, profile updates, order management, billing, shipping, returns, loyalty points, subscriptions, and more. Testing shows the agent frequently selects the wrong tool, especially between similar tools like update_billing_address and update_shipping_address.',
  'What anti-pattern is causing the tool selection failures?',
  '["The tool descriptions need more detail to differentiate similar tools", "Giving a single agent 18+ tools degrades selection accuracy rapidly, especially with similar tools. Restructure into specialized subagents with 4-5 tools each — an account agent, an order agent, a billing agent — each scoped to its domain", "The tools should be renamed with clearer prefixes to help the model distinguish them", "Set tool_choice to force the correct tool based on detected keywords in the user''s message"]'::jsonb,
  1,
  'ANTI-PATTERN: Giving one agent too many tools. Tool selection accuracy degrades rapidly above 5 tools, and similar tools create ambiguity. The fix is distributing tools across specialized subagents (4-5 tools each) so each agent has a focused, manageable tool set. Option A helps marginally but doesn''t fix the volume problem. Option C is cosmetic. Option D bypasses the model''s natural selection ability and is brittle.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  75,
  'tool_design_mcp',
  'Your MCP server configuration file (.mcp.json) is committed to the project repository and contains the database connection string directly: {"db_tool": {"connection": "postgresql://admin:s3cret@prod-db:5432/main"}}. A new team member clones the repo and immediately has database access.',
  'What critical anti-pattern does this represent?',
  '["The connection string should use a read-only database user instead of admin", "Hardcoding secrets in .mcp.json is a critical security anti-pattern because config files are committed to git. Use ${DB_CONNECTION_STRING} environment variable expansion so secrets stay in each developer''s environment, not in version-controlled files", "The .mcp.json file should be added to .gitignore so it is not committed", "The database should use IP-based access control instead of password authentication"]'::jsonb,
  1,
  'ANTI-PATTERN: Hardcoding API keys and secrets in .mcp.json. Configuration files are committed to git, so hardcoded secrets get leaked — even in private repos, they persist in git history. Use ${ENV_VAR} environment variable expansion so secrets stay in the environment. Option A reduces damage but doesn''t fix the exposure. Option C prevents sharing the config structure with the team. Option D is a separate security layer, not a fix for credential exposure.'
);

-- ── Claude Code Config anti-patterns ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  76,
  'claude_code_config',
  'Your CI/CD pipeline uses Claude Code to both generate code fixes and review them in the same session. The pipeline runs: claude -p "Fix the failing test, then review your fix for any issues." The review step consistently reports "the fix looks correct" even when the generated code has subtle bugs that human reviewers later catch.',
  'What anti-pattern explains the ineffective self-review?',
  '["The review prompt needs more specific criteria for what to check", "Same-session self-review creates confirmation bias — the reviewer retains the generator''s reasoning context and is predisposed to approve its own work. Use separate sessions: one to generate the fix, another fresh session to review the output objectively", "The model needs extended thinking enabled to catch subtle bugs during review", "Add a third step where the agent re-reviews its review for missed issues"]'::jsonb,
  1,
  'ANTI-PATTERN: Same-session self-review in CI/CD. The reviewer shares the generator''s context, creating confirmation bias — it already "knows" why the fix is correct and is predisposed to agree with itself. A fresh session reviews the code objectively with no preconceptions. Option A adds specificity but doesn''t fix the bias. Option C adds reasoning depth but within the same biased context. Option D compounds the bias with another self-review.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  77,
  'claude_code_config',
  'A developer adds their personal preferences to the project''s .claude/CLAUDE.md file: preferred tab width, comment style, import ordering, and a note saying "always use dark mode syntax highlighting in code blocks." Other team members complain that Claude is now enforcing one person''s style preferences on everyone.',
  'What anti-pattern is this, and how should personal preferences be configured?',
  '["The preferences should be marked as optional in CLAUDE.md with a note that they can be overridden", "Personal preferences belong in ~/.claude/CLAUDE.md (user-scoped), not in .claude/CLAUDE.md (project-scoped). Project-level CLAUDE.md should only contain team-agreed standards. Each configuration layer has a specific purpose and audience", "The team should vote on which preferences to keep in the project CLAUDE.md", "Create a CLAUDE.local.md for each developer with their own preferences instead"]'::jsonb,
  1,
  'ANTI-PATTERN: Putting personal preferences in project-level CLAUDE.md. Project-level configuration should contain team-agreed standards only. Personal preferences (editor settings, style choices) belong in ~/.claude/CLAUDE.md which is user-scoped and not version-controlled. Option A creates ambiguity about which rules to follow. Option C forces consensus on preferences that should be individual. Option D is partially correct — CLAUDE.local.md works for project-specific personal overrides, but the general fix is understanding the configuration hierarchy.'
);

-- ── Prompt Engineering anti-patterns ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  78,
  'prompt_engineering',
  'Your CI code review pipeline uses the prompt: "Review this code thoroughly and find all issues." In production, the review flags 15 findings per PR with a 48% false positive rate. Developers have stopped reading the reviews because they don''t trust the output.',
  'What anti-pattern is causing the high false positive rate and developer distrust?',
  '["The model needs few-shot examples of what constitutes a real issue", "Vague instructions like ''be thorough'' and ''find all issues'' produce over-flagging and false positives. Replace with explicit, measurable criteria: ''flag functions exceeding 50 lines, unused imports, SQL queries without parameterized inputs.'' Specific criteria produce consistent, actionable results that build trust", "The model should be configured to only report high-confidence findings", "Reduce the scope to only security issues where false positives are more tolerable"]'::jsonb,
  1,
  'ANTI-PATTERN: Vague instructions. "Be thorough" and "find all issues" are ambiguous — the model over-flags to satisfy the perceived expectation. Explicit, measurable criteria produce consistent, actionable results. Option A helps but doesn''t fix the root ambiguity. Option C filters after generation rather than preventing bad generation. Option D reduces scope without fixing the instruction quality.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  79,
  'prompt_engineering',
  'Your team switched from prompt-based JSON output to tool_use with a JSON schema, and syntax errors dropped to zero. However, you''re now seeing a different class of errors: the JSON is always valid, but 8% of extractions contain incorrect values — dates are wrong, amounts are transposed, or fields reference the wrong entity in the source document.',
  'What anti-pattern does this reveal about relying solely on tool_use?',
  '["The JSON schema needs more constraints to catch value-level errors", "Assuming tool_use guarantees semantic correctness is an anti-pattern. tool_use guarantees STRUCTURE only — valid JSON with correct field types. Values inside the JSON may still be wrong. Add business rule validation after tool_use to check semantic correctness (do amounts sum correctly? are dates in valid ranges?)", "The model needs more context about the source document to extract values correctly", "Switch back to prompt-based output and add a validation step"]'::jsonb,
  1,
  'ANTI-PATTERN: Assuming tool_use guarantees semantic correctness. Tool use with JSON schemas guarantees structure (valid JSON, correct types, required fields) but NOT that the values are correct. Schema compliance + semantic validation together ensure both correct format AND correct content. Option A can''t express semantic rules in JSON schema. Option C may improve accuracy but doesn''t catch errors. Option D goes backward on structural guarantees.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  80,
  'prompt_engineering',
  'Your extraction pipeline retries failed extractions with the message: "There were errors in the previous extraction. Please try again more carefully." After 3 retries, the success rate improves by only 2%, and the same errors recur.',
  'Why are retries ineffective, and what should the retry message include?',
  '["The retry limit should be increased to 5 attempts to give the model more chances", "Generic retry messages give the model no signal about what to fix. Append specific error details: which field failed, what the extracted value was, what was expected, and the relevant section of the source document. Specific feedback gives the model a clear correction target", "The model should be switched to a higher-capability tier for retries", "Add a temperature reduction on each retry to make the model more deterministic"]'::jsonb,
  1,
  'ANTI-PATTERN: Generic retry messages. "Try again more carefully" tells the model nothing about what went wrong. Without specific error details (which field, what was wrong, expected vs actual), the model has no signal for what to fix and will likely repeat the same mistake. Option A adds more blind retries. Option C changes the model without addressing the feedback problem. Option D affects randomness, not accuracy.'
);

-- ── Context Management anti-patterns ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  81,
  'context_management',
  'Your customer support agent maintains conversation context through progressive summarization — every 10 turns, it summarizes the conversation so far and uses that summary going forward. A customer calls about a $847.50 refund discussed 25 turns ago. The agent responds with an incorrect amount of $850, having lost the precise figure through two rounds of summarization.',
  'What anti-pattern caused the incorrect amount, and what is the correct approach?',
  '["The summarization interval should be reduced to every 5 turns to preserve more detail", "Progressive summarization of critical customer details is an anti-pattern because each summarization round loses specifics like names, IDs, amounts, and dates. Use immutable ''case facts'' blocks positioned at the start of context that are never summarized — they sit in a high-recall position and preserve exact values throughout the conversation", "The agent should store all amounts in an external database and retrieve them when needed", "Use lossless compression instead of summarization to preserve all details"]'::jsonb,
  1,
  'ANTI-PATTERN: Progressive summarization of critical customer details. Each round of summarization loses specifics: names, IDs, amounts, dates. The fix is immutable "case facts" blocks at the start of context that are never summarized. They sit in a high-recall position (beginning of context) and preserve exact values. Option A reduces information loss but doesn''t prevent it. Option C adds infrastructure when the problem can be solved with prompt architecture. Option D doesn''t exist for LLM context.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  82,
  'context_management',
  'Your document extraction system reports 95% overall accuracy across all document types. Leadership is satisfied. However, when you stratify the results, you discover: invoices are at 70% accuracy, receipts at 99%, and purchase orders at 98%. The low invoice accuracy is hidden by the high volume of receipts.',
  'What anti-pattern does this illustrate?',
  '["The 95% threshold is too low — set a target of 99% overall accuracy", "Relying on aggregate accuracy metrics only is an anti-pattern because they mask per-category failures. Invoices at 70% are unacceptable but invisible in the 95% aggregate. Track accuracy per document type (stratified metrics) to reveal hidden failures that aggregate metrics conceal", "The invoice extraction model needs separate fine-tuning", "Weight the accuracy by document importance rather than volume"]'::jsonb,
  1,
  'ANTI-PATTERN: Aggregate accuracy metrics only. Overall metrics hide category-specific problems. Invoices at 70% while receipts at 99% still averages to ~95% if receipts dominate volume. Per-type tracking (stratified metrics) reveals hidden failures. Option A raises the bar without revealing where failures occur. Option C jumps to a solution without diagnosing properly. Option D partially helps but still masks individual category performance.'
);

-- ============================================================================
-- DOMAIN DEEP-DIVE QUESTIONS
-- Filling gaps from claudecertifications.com domain study guides
-- ============================================================================

-- ── Tool Design: Built-in tool selection ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  83,
  'tool_design_mcp',
  'A developer is debugging a production issue and needs to find all files that import from a deprecated module called "legacy-auth". They write a Bash command: claude -p "Run: grep -r ''legacy-auth'' src/ --include=*.ts" to search the codebase.',
  'What is wrong with this approach?',
  '["The grep flags are incorrect — it should use --include=\"*.ts\" with quotes", "Bash should never be used for file content searches when the dedicated Grep built-in tool exists. Grep is purpose-built for searching inside files and provides better results than shell commands", "The search should use find + xargs instead of grep -r for better performance", "Nothing is wrong — Bash with grep is the standard approach for code search"]'::jsonb,
  1,
  'Built-in tools should always be preferred over their Bash equivalents: Read over cat, Edit over sed, Grep over grep command, Glob over find, Write over echo. The dedicated tools provide better integration, are easier to review, and produce cleaner results. This is a frequently tested concept on the exam.'
);

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  84,
  'tool_design_mcp',
  'A junior developer needs to fix a bug on line 42 of a configuration file. They use the Write tool to output the entire file with the fix applied. A senior developer reviews the change and flags it.',
  'Why is using Write incorrect here, and what should be used instead?',
  '["Write is fine for small files — the senior developer is being overly cautious", "Write replaces the entire file and should only be used for creating new files. For modifying existing files, use the Edit tool which makes targeted, precision changes without risking unintended modifications to other lines", "Write should be used with a backup flag to preserve the original file", "The developer should use Bash with sed to make the targeted change instead"]'::jsonb,
  1,
  'Write replaces entire file contents and should only be used for new files. Edit makes targeted modifications to existing files. Using Write for a single-line fix risks accidentally changing other parts of the file. Bash with sed is also wrong — Edit is the dedicated tool for this purpose.'
);

-- ── Prompt Engineering: Few-shot optimal count ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  85,
  'prompt_engineering',
  'You are building a customer review classifier that needs to handle sarcasm, mixed sentiment, and ambiguous language. A teammate proposes adding 12 few-shot examples to cover every possible edge case they can think of.',
  'What is the optimal number of few-shot examples, and why is 12 too many?',
  '["12 examples is fine — more examples always improve accuracy for complex classification tasks", "2-4 examples is optimal. Include one clear positive, one clear negative, one mixed sentiment, and one edge case (like sarcasm). More than 6 examples bloats the prompt without improving accuracy and wastes context tokens", "Use only 1 example to establish the format, then rely on clear instructions for the classification criteria", "Few-shot examples are unnecessary for classification — use tool_use with an enum schema instead"]'::jsonb,
  1,
  'Research shows 2-4 few-shot examples is the sweet spot. Fewer than 2 doesn''t establish a pattern; more than 4-6 adds token cost without improving quality. Each example should be diverse: cover different categories and include at least one edge case. Option A wastes tokens. Option C is too few. Option D is valid for output format but doesn''t help with ambiguous classification.'
);

-- ── Claude Code: TDD iteration pattern ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  86,
  'claude_code_config',
  'You ask Claude Code to "implement a rate limiter for the API." After two iterations, the implementation still doesn''t match your requirements — it uses a fixed window instead of sliding window, and the error responses don''t include retry-after headers.',
  'What iteration pattern would most effectively improve the output quality?',
  '["Provide a more detailed specification with every requirement listed explicitly", "Use TDD iteration: write failing tests that define the exact expected behavior (sliding window, retry-after headers), then have Claude implement to pass the tests. Tests serve as an unambiguous specification", "Switch to plan mode and have Claude design the architecture before implementing", "Add few-shot examples showing correct rate limiter implementations from other codebases"]'::jsonb,
  1,
  'TDD iteration dramatically improves output quality compared to describing features in prose. Tests serve as unambiguous specifications — they define exact inputs, outputs, and edge case behavior. Claude implements to pass the tests, then you run them to verify. Option A may still be ambiguous in prose. Option C helps with architecture but not implementation details. Option D may not match your specific requirements.'
);

-- ── Context Management: Scratchpad files ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  87,
  'context_management',
  'Your agent is conducting a multi-hour investigation of a production incident. After extensive exploration, the context window is nearly full. You need to use /compact to free up space, but you''re worried about losing the key findings discovered so far — specific file paths, error patterns, and a hypothesis about the root cause.',
  'How should you preserve critical findings before compacting?',
  '["Copy the findings into the system prompt so they survive compaction", "Write findings to a scratchpad file (e.g., progress.md) before compacting. Scratchpad files persist on the filesystem across context resets and session boundaries. After compaction, re-read the file to restore context", "Don''t compact — start a new session instead and verbally summarize findings", "Rely on compaction to preserve the most important information automatically"]'::jsonb,
  1,
  'Scratchpad files are the recommended pattern for persisting state across context resets. They survive compaction events and session boundaries because they exist on the filesystem, not in the context window. After compacting, the agent can re-read the file to restore its understanding. Option A has size limits and is brittle. Option C loses tool call context. Option D is unreliable — compaction may lose specific details like file paths and error patterns.'
);

-- ── Context Management: Subagent delegation for verbose exploration ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  88,
  'context_management',
  'Your coordinator agent needs to analyze a large codebase to understand its architecture. The analysis requires reading dozens of files, running grep searches, and examining dependency graphs. This verbose exploration would fill the coordinator''s context window with intermediate results, leaving little room for the actual task of designing a migration plan.',
  'What is the most effective way to handle this verbose exploration?',
  '["Have the coordinator read files selectively, using Glob and Grep to target only the most relevant files", "Delegate the verbose exploration to a subagent. The subagent performs all the reading and searching in its own isolated context, then returns only a synthesized summary to the coordinator, keeping the coordinator''s context clean", "Use /compact periodically during exploration to free up context space", "Split the task into multiple sessions, exploring in one and planning in another"]'::jsonb,
  1,
  'Delegating verbose work to subagents is a key context management pattern. The subagent has its own context window for exploration noise, and only the synthesized result returns to the coordinator. This keeps the coordinator''s context clean for the actual planning task. Option A is good practice but may still fill context with many files. Option C loses intermediate findings. Option D adds complexity and loses continuity.'
);

-- ── Agentic Architecture: Context passing to subagents ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  89,
  'agentic_architecture',
  'Your coordinator agent delegates research tasks to three subagents. To ensure each subagent has full context, the coordinator passes its entire conversation history (including previous subagent results, user interactions, and internal reasoning) to every subagent.',
  'What problem does sharing full coordinator context with subagents create?',
  '["There is no problem — more context always helps subagents produce better results", "Sharing full coordinator context wastes tokens on irrelevant information and confuses subagents with context outside their task scope. Pass ONLY the context specific to each subagent''s assigned task", "The coordinator context might contain sensitive information that shouldn''t be shared with certain subagents", "Full context sharing creates circular dependencies if subagent results reference each other"]'::jsonb,
  1,
  'Context pollution is a key anti-pattern tested heavily on the exam. Subagents should receive only context relevant to their specific task — not the full coordinator conversation. Irrelevant context wastes tokens and can confuse the subagent with information outside its scope, degrading output quality. Option A is wrong — more irrelevant context hurts. Option C is a valid concern but not the primary issue. Option D is unlikely in practice.'
);

-- ── Prompt Engineering: Enum with "other" category ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  90,
  'prompt_engineering',
  'Your document extraction tool uses a JSON schema with a document_type enum field: ["invoice", "receipt", "purchase_order"]. In production, 5% of documents are credit notes, which don''t match any enum value. The extraction fails silently on these documents because the constrained output can''t represent the actual document type.',
  'How should you design the enum to handle unexpected document types?',
  '["Add every possible document type to the enum to cover all cases", "Include an \"other\" category in the enum plus a separate document_type_detail text field where the model can specify the actual type when \"other\" is selected", "Remove the enum constraint and use a free-text field for document type", "Add a pre-processing classifier that rejects unsupported document types before extraction"]'::jsonb,
  1,
  'Including "other" in enums with a detail field is a best practice for handling unexpected values while maintaining schema structure. Option A can''t anticipate every type. Option C loses the benefits of constrained output (consistent values for downstream processing). Option D rejects potentially valuable documents rather than processing them.'
);

-- ── Context Management: Confidence-ranked provenance ──

INSERT INTO quiz_questions (quiz_id, position, domain, scenario, prompt, options, correct_index, explanation)
VALUES (
  (SELECT id FROM quizzes WHERE slug = 'cca-daily-pool'),
  91,
  'context_management',
  'Two subagents in your research system provide conflicting data about a company''s revenue. The web search agent found "$50M revenue" from a news article summary. The document analysis agent extracted "$47.3M revenue" directly from the company''s annual report PDF.',
  'How should the coordinator resolve this conflict?',
  '["Average the two values and report $48.65M as the most likely figure", "Use provenance metadata to rank by confidence: the document analysis extraction (''extracted'' from primary source) outranks the web search finding (''inferred'' from secondary summary). Select the $47.3M figure and log the conflict for audit", "Report both values and let the user decide which is correct", "Discard both values since they conflict, and flag the field as unresolvable"]'::jsonb,
  1,
  'Provenance-based conflict resolution uses confidence ranking: verified (authoritative sources) > extracted (parsed from structured documents) > inferred (derived from context) > estimated (best guess). The annual report extraction is a primary source with higher confidence than a news article summary. Option A produces a meaningless average. Option C pushes the decision to the user unnecessarily. Option D discards valid data.'
);

-- Update the question_count to reflect the final total
UPDATE quizzes SET question_count = 91 WHERE slug = 'cca-daily-pool';
