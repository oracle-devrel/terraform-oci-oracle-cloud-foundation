# Design Live AI Hub Skill

This directory packages a project-scoped Codex skill for designing governed AI workloads over live, distributed enterprise data.

## Files

- `.codex/skills/design-live-ai-hub/SKILL.md` — the Codex skill entry point and instructions. 
- `README.md` — this overview and usage guide.

## Load the skill in Codex

Open this `skills` directory as the project folder in Codex. Project-scoped skills use `.codex/skills/<skill-name>/SKILL.md`; Codex can then discover the skill by its frontmatter name, `design-live-ai-hub`. Start or refresh a conversation in that project and invoke `$design-live-ai-hub` or select it from the skills picker.

For reliable architecture guidance, provide what you know about:

- The business outcome, users, and example questions or actions
- Source systems and their available interfaces
- Freshness and response-time needs
- Sensitive data, locality, and regulatory constraints
- Success measures and platform constraints

The skill should distinguish requirements, assumptions, and open decisions; recommend a staged design; and include validation and security checkpoints. Current Oracle product names, features, limits, APIs, and implementation steps must be verified against official Oracle documentation. The Fashion Advisor and other product choices are examples, not required architecture.

## Source context

The skill uses Oracle's *Live AI Hub User Guide*, draft version 0.1, June 2026, as design guidance. That draft is not a product guarantee or delivery commitment; verify current product details before presenting them as facts.

Source PDF: [Live AI Hub User Guide draft](https://github.com/oracle-devrel/terraform-oci-oracle-cloud-foundation/blob/main/Live-AI-Hub/documentation/Live%20AI%20Hub%20User%20Guide%20draft.pdf)

Codex skill format and repo-scoped location: [OpenAI Developers — Testing Agent Skills Systematically with Evals](https://developers.openai.com/blog/eval-skills)
