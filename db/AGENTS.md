# Crimson Community schema
Read `.agents/skills/project-schema-review/SKILL.md` before migration/index changes. Profile-visit data can grow continuously: review retention/query cadence, indexes, existing rows, null/FK/delete behavior, lock cost, and recovery. Never destructively modify production history during development.
