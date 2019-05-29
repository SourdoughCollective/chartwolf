# chartwolf
Graphviz pre-processor allowing for semantic styling and a more natural table markup.

## The Name

It creates flowcharts and "wolf" is "flow" backwards.

## Dependencies

- ruby
- graphviz

## Purpose

Chartwolf's prime purpose is to make semantic information divisions *within* nodes as intuitive to create as graphviz makes semantic connections *between* nodes.

Chartwolf's secondary purpose is to allow easier styling of nodes and edges. (e.g. Nodes presenting a counterargument in red; nodes presenting a supporting argument in green; etc.)

## Background

Chartwolf grew out of my desire to use graphviz to show the connections between ideas and arguments in philosophy. It felt easy only to show the connections using edges between nodes, but I wanted an intuitive visual clue whether a connection was close or far. Using tables within nodes allowed for this, but only the HTML-like syntax allows for true flexibility, and HTML tables are very fiddly.

## Rationale

Table syntax is notoriously difficult. Choose two of:
1. editing ease
2. semantic syntax
3. quasi-WYSIWYG (in the way Markdown as a whole is quasi-WYSIWYG and XML is not).

Most table syntaxes (e.g. most flavours of Markdown) choose 3 over 2 over 1, relying on editor plugins to simplify the editing process. Chartwolf prioritises 2 over 3, with some edge-case concessions to 1. Rather than try to reproduce the table's visual appearance, we borrow from markdown list syntax to create a simple, intuitive, and (usually) semantically meaningful markup. 

This syntax will not be appropriate for all table-creation use-cases. Aside from other issues, the semantic relationship gets lost with more columns. The formatting of graphviz nodes as tables, however, is an appropriate use-case, as these should have relatively few columns (and even rows).

## Brief introduction to the syntax

(See wiki for more detail.)

```
#Aristotles_Functional_Argument
-* Aristotle's Functional Argument
- Step 1
- Step 2
- Step 3
```

```
#Varieties_of_Utilitarianism
-* Varieties of Utilitarianism
+ Variety 1
+ Variety 2
+ Variety 3
```

## TODO

- whitespace on RHS of nodes. (Maybe Linux-only?)
