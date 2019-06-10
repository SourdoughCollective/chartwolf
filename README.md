# chartwolf
Graphviz pre-processor allowing for semantic styling and a more natural table markup.

## The Name

It creates flowcharts and "wolf" is "flow" backwards.

## Dependencies

- ruby
- graphviz (DOT->SVG)
- inkscape (SVG->PDF)

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

In a nutshell:

- `# sentence` is a comment
 - Note the space between pound-sign and comment text.
- `#Aristotles_Functional_Argument` is the name that graphviz will know the node by.
 - Always first line
 - No space between `#` and name.
- `{{default}}` is the style.
 - Second line (TODO: option include this in name line instead).
- `- sentence sentence sentence` is a new item in a *vertical* list (a 'stack' -- the hyphen looks like a pancake)
- `+ sentence sentence sentence` is a new item in a *horizontal* list (the plus sign doesn't look like a pancake)
- `-* sentence sentence sentence` and `+* sentence sentence sentence` are as before but their table cell is highlighted (i.e. font colour becomes background colour and vice versa).
- indenting by one space more than the previous item turns an item into a child of the previous item.

### Example 1

```
#Aristotles_Functional_Argument
-* Aristotle's Functional Argument
- Step 1
- Step 2
- Step 3
```
produces:
```
Aristotles_Functional_Argument [label = <
<TR><TD>Aristotle's Functional Argument</TD></TR>
<TR><TD>Step 1</TD></TR>
<TR><TD>Step 2</TD></TR>
<TR><TD>Step 3</TD></TR>>]
```

### Example 2

```
#Varieties_of_Utilitarianism
-* Varieties of Utilitarianism
+ Variety 1
+ Variety 2
+ Variety 3
```
produces:
```
Varieties_of_Utilitarianism [label = <
<TR><TD>Varieties of Utilitarianism</TD></TR>
<TR><TD>Variety 1</TD><TD>Variety 2</TD><TD>Variety 3</TD></TR>>]
```

### Example 3

```
#Aristotles_Argument_with_Comments
-* Aristotle's Argument
- Step 1
 - Comment on step 1
- Step 2
 - Comment on step 2
- Step 3
 - Comment on step 3
```
produces:
```
Aristotles_Argument_with_Comments [label = <
<TR><TD>Aristotle's Argument</TD></TR>
<TR><TD>Step 1</TD><TD>Comment on Step 1</TD></TR>
<TR><TD>Step 2</TD><TD>Comment on Step 2</TD></TR>
<TR><TD>Step 3</TD><TD>Comment on Step 3</TD></TR>>]
```

## TODO

- whitespace on RHS of nodes. (Maybe Linux-only?)
