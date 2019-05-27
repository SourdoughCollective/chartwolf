# chartwolf
Graphviz pre-processor allowing for semantic styling and a more natural table markup.

## The Name

It creates flowcharts. "Wolf" is "flow" backwards.

## Dependencies

ruby
graphviz

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
