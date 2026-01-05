---
title: Final Project
headerImg: pier.jpg
---

You will do the project in a  **in a group of 4** over
the *second half* of the quarter and will evaluate it
with a demo during the final exam time block.

The project will comprise 30% of your overall grade.

You are expected to spend at least **30 hours** (each)
in the project.

## Goals and Timeline

The goal of the project is to give you some hands on
experience with building a realistic application using
the principles learned in CSE 230.

 					 
- **Friday 11/17** Proposal [Submit here](https://forms.gle/uZsyvUgmKGWRxc9X6)
- **Friday 12/1** Updates
- **Friday 12/15** Demonstration

The overall goal is for *you* to write an application
from scratch, so we will provide very basic starter
code, just containing the bare library dependencies.
You are free to use any existing open source libraries
to build your application.

## Ideas

For the project you will implement any **line application**
using [the `brick` library](https://github.com/jtdaugherty/brick/).

You can think of any application you wish. If you think your idea
is unrealistic, discuss it with the course staff. Of course, it
should not be *any of* the projects already listed or implemented
by others, doing so or **any of plagiarism will result in
a score of zero**.

Here are some ideas for you to get started

- A clone of the [`fish` shell](https://fishshell.com/) with history-based autocomplete
- An arcade game like `breakout` or `space invaders`
- A networked two player game e.g., chess, checkers, scrabble etc.
- A networked chat/irc/slack client
- A vim/editor clone, extended with support for shared editing
- A puzzle solver, e.g., sudoku.

Feel free to think of other applications!

## Evaluation

The project will be evaluated based on the following criteria:

- *collaboration:* the project will be a public repo on [github](https://github.com/) and all members should contribute equally.
- *library usage:* the project should use existing libraries of the [hackage](https://hackage.haskell.org/) ecosystem.
- *reproduction:* the project should be easily installed via [cabal](https://www.haskell.org/cabal/) or [stack](https://docs.haskellstack.org/en/stable/README/).
- *unit testing:* the project should pass unit tests that are implemented either manually or using [quickcheck](https://hackage.haskell.org/package/QuickCheck).
- *presentation:* make sure to clearly present your goals and your implementation.

### Milestone 1: Registration and Proposal

1. Create a `github` repository for your project with a `README.md`
   that describes your proposed application and its goals in 300 words.

2. Fill up a google form (to be shared) linking your project and team members.


### Milestone 2: Updates

Update your `README` with

- What is the architecture of your application (the key components)?
- What challenges (if any) did you have so far and how did you solve them?
- Do you expect to meet your goals until the deadline?
- If not, how will you modify your goals?

### Milestone 3: Demonstration

You will give a **10 min** demonstration of your project during an open
"poster session" to be conducted during the finals slot **Friday 12/10 from 11:30am -- 2:30pm**.


## Final Demo: Plan and Rubric

### Demo Outline

Each group’s presentation should comprise the following components:

* Prepared presentation: (8 minutes)

   * An overview of the project, including a high-level walkthrough of the architecture;
   * A demo of the project;
   * One interesting or challenging bit about the project.

* A follow-up discussion / interactive session with the evaluator and the group. (7 minutes)


The first three components can be done live or with a prerecorded video.

Please keep your prepared presentation under 8 minutes (**time limit will be strictly enforced**).

Additionally, please make sure to show up to your time slot on time.

### Requirements for Prepared Presentation

We are allowing flexibility here for groups to either
do a live presentation or a pre-recorded video. The
format of the presentation or video is totally up to you.
It does NOT have to be a PowerPoint presentation,
though some visual aids are expected. Feel free to
get creative with format, style, etc., in the way
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

* Video/presentation is creative and engaging
* Video/presentation conveys all of the required information
* Video/presentation clearly communicates information
* Demo shows the interactivity of your project
* Timing is appropriate
* Able to run project interactively for the evaluator
* Able to navigate and discuss code relevant to interactive demo

Pass:

* Does not meet one or more of the High Pass criteria.

Not Pass:

* Meets few or none of the High Pass criteria.
