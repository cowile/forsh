# Forsh

## Description

Forsh is a shell built on top of Gforth. It allows one to easily operate a Unix-like OS without leaving the gforth environment and can serve as a fully featured replacement to the Bourne Shell and derivatives such as Bash.

## Introduction

To fully take advantage of Forsh, it is recommended one have a reasonable understanding of the Forth language and underlying environment. The rest of this guide will be predicated on such knowledge, but first, a few examples.

`c ls $` executes the ls command. c is a parsing word that takes word after it as the program name to be executed. $ executes the program. This is equivalent to just `ls` at a regular BAsh prompt.

`c ls s a $` is close to the same. s is similar to c, but s takes the following character as a short option. long options use the letter l. That line is the same as `ls -a` in Bash.

## Motivation

Bash is no doubt a familiar tool to anyone who wants maximum control and power over their OS. Command lines remain unmatched in their power and expressiveness in telling the computer what to do and are likely to remain so for some time. Unfortunately, the main shell languages in use are full of quirks, tricks, and traps that counfound new and veteran users alike. Some of the problems with Bash include but are not limited to:

* complex and arcane syntax
* a slew of metacharacters that must be understood and quoted when appropriate
* different behaviors for different kinds of quoting
* no structured data, everything is a string
* second-class programming language constructs

However, Bash and kin have proven remarkably sticky as shell languages due to several advantages such as:

* Concise notation for common shell actions
* ease of I/O redirection
* ease of pipeline creation
* prioritization of the interface over the language

Forsh was created to bring the advantages of Bash to a proper programming environment.

## Using Forsh

Forsh works by utilizing the underlying Forth interpreter. In Forth, programs consist of "words". A Word is any sequence of printable characters. Words are separated by whitespace.
