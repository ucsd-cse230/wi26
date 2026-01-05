---
title: Final Project
headerImg: pier.jpg
---

You will do the project in a **in a group of 2-3** over the _second half_ of the quarter.

We will evaluate the project with a **live demo and Q&A** during the final exam block **Th _03/19/2026_, 8:00a-11:00a**.

The project will comprise 20% of your overall grade.

You are expected to spend approximately **20 hours** (each) in the project.

## Goals and Timeline

The goal of the project is to give you some hands on
experience with building a realistic application using
the principles learned in CSE 230.

- **Thu 2/19** Proposal [Submit here](https://forms.gle/ACFX2ZhUokmA4rMH8)
- **Fri 3/6** Updates
- **Thu 3/19** Demonstration

The overall goal is for _you_ to write an application
from scratch, so we will provide very basic starter
code, just containing the bare library dependencies.
You are free to use any existing open source libraries
to build your application.

## Ideas

For the project you will implement a **concurrent**,
**real-time**, **multiplayer**, game, using the
[`tokio`](https://tokio.rs/) library.

As baseline option, you can implement a multiplayer "snake" game that uses
tokio + [`ratatui`](https://ratatui.rs/) (terminal UI library) to allow multiple players to
play snake in the terminal over the network, see this [little demo](TODO:SNAKE-DEMO-URL).
You can think of any game you wish. If you think your idea is unrealistic, or too easy or
difficult, feel free to discuss it with the course staff.

## Evaluation

The project will be evaluated based on the following criteria:

- _collaboration:_ the project will be a public repo on [github](https://github.com/)
  and all members should contribute equally,
- _library usage:_ the project should use existing Rust crates from the [crates.io](https://crates.io/) ecosystem,
- _reproduction:_ the project should be easily installed via [cargo](https://doc.rust-lang.org/cargo/), and should include instructions to reproduce the setup.
- _presentation:_ make sure to clearly present your goals and your implementation,
- _interrogation:_ be prepared to answer questions about your code and design choices.

### Milestone 1: Registration and Proposal

1. Create a `github` repository for your project with a `README.md`
   that describes your proposed application and its goals in 200 words
   or just "snake" + additional features if you're doing that.

2. Fill up a google form (to be shared) linking your project and team members.

### Milestone 2: Updates

Update your `README` with

- What is the architecture of your application (the key components)?
- What challenges (if any) did you have so far and how did you solve them?
- Do you expect to meet your goals until the deadline?
- If not, how will you modify your goals?

### Milestone 3: Demonstration

You will give a **10 min** demonstration of your project during an open
"poster session" to be conducted during the finals slot **Thu 03/19 from 8:00am -- 11:00am**.

## Final Demo: Plan and Rubric

### Demo Outline

Each group’s presentation should comprise the following components:

- Prepared presentation: (8 minutes)

  - An overview of the project, including a high-level walkthrough of the architecture;
  - A demo of the project;
  - One interesting or challenging bit about the project.

- A follow-up discussion / interactive session with the evaluator and the group. (7 minutes)

The first three components can be done live or with a prerecorded video.

Please keep your prepared presentation under 8 minutes (**time limit will be strictly enforced**).

Additionally, please make sure to show up to your time slot on time.

### Requirements for Prepared Presentation

We are allowing flexibility here for groups to either
do a live presentation or a pre-recorded video.

The format of the presentation or video is totally up to you.
It does NOT have to be a PowerPoint presentation,
though some visual aids are expected.

Feel free to get creative with format, style, etc., in the way
that helps you best convey the information above.

### Overview of the Project

Your project overview should cover at least the following aspects:

1. What is your project?
   E.g., if you built a game, what is the game and what are its rules?

2. What is the architecture of your project (the key components)?
   E.g., how did you model the board / movements / characters / …?

### Demo

Your demo should show at least the following:

1. The interface of your project;
2. How a user interacts with the interface;
3. The features you implemented.

### Interesting / Challenging Bit

Show us one part of the implementation that was
interesting / complicated / challenging to implement,
or something you’re proud of.

This should involve your code.

For instance, show us a function that implements
some interesting game logic or walk us through
how you split up the modules so that they could
be implemented independently between your teammates.

### Structure of Follow-Up / Interactive Session

In this part of your presentation, you will run
your project live for the evaluator. The evaluator
will prompt you for how to interact with the program,
which may include input that leads to buggy behavior.

That’s okay!

After this interactive demo, your evaluator will
ask you to walk through part of the code related
to the interactive demo. This may include a request
to explain code relevant to buggy behavior.

Make sure you are prepared to navigate your codebase when asked.

## Final Grading Rubric

High Pass:

- Video/presentation is creative and engaging
- Video/presentation conveys all of the required information
- Video/presentation clearly communicates information
- Demo shows the interactivity of your project
- Timing is appropriate
- Able to run project interactively for the evaluator
- Able to navigate and discuss code relevant to interactive demo

Pass:

- Does not meet one or more of the High Pass criteria.

Not Pass:

- Meets few or none of the High Pass criteria.
