# Knowledge Checks

Each section has a `quiz.yaml` with 18 questions, and the course has `sections/final-domain-quiz.yaml` with 18 questions. Each file is listed in `astrona.yaml` as a `type: quiz` entry with `pass_score: 70`. The section quiz follows the capstone lab of its section. The final quiz is the last entry of the course.

## Fields

- `id`: stable identity of the bank or the question. Keep it when you edit wording.
- `scope`: the section or the domain.
- `learning_objective`: the measurable outcome that the question checks.
- `source_readings`: the reading parts that teach the answer. This is for authors and not for learners.
- `prompt`: the question text.
- `options`: stable option IDs, the answer text and feedback for each option.
- `correct_option`: the ID of the single correct option.
- `explanation`: the feedback that reinforces the supported answer.

The files contain answer keys and are public practice material. They are not official exam questions and a score is not an official CCA result.
