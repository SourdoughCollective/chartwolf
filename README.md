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

Most table syntaxes (e.g. most flavours of Markdown) choose 3 over 2 over 1, relying on editor plugins to simplify the editing process. HTML prioritises 2 over 3, with costs to 1. Chartwolf prioritises 2 over 3, with some edge-case concessions to 1. Rather than try to reproduce the table's visual appearance, we borrow from markdown list syntax to create a simple, intuitive, and (usually) semantically meaningful markup. 

This syntax will not be appropriate for all table-creation use-cases. Aside from other issues, the semantic relationship gets lost with more columns. The formatting of graphviz nodes as tables, however, is an appropriate use-case, as these should have relatively few columns (and even rows).

## Brief introduction to the syntax

(See wiki for more detail.)

In a nutshell:

- `# sentence` is a comment
  - Note the space between pound-sign and comment text.
- `#Aristotles_Function_Argument` is the name that graphviz will know the node by.
  - Always first line
  - No space between `#` and name.
- `{{default}}` is the style.
  - Second line (TODO: option include this in name line instead).
- `- This is a sentence` is a new item in a *vertical* list (a 'stack' -- the hyphen looks like a pancake)
- `+ This is a sentence` is a new item in a *horizontal* list (the plus sign doesn't look like a pancake)
- `-* This is a sentence` and `+* This is a sentence` are as above but their table cell is highlighted (i.e. font colour becomes background colour and vice versa).
- Indenting by one space more than the previous item turns an item into a child of the previous item.

### Example 1

```
#Aristotles_Function_Argument
{{default}}
-* Aristotle's Function Argument
- Step 1
- Step 2
- Step 3
```
produces the following pure graphviz syntax:
```
Aristotles_Function_Argument [label = <
<TABLE ALIGN="LEFT" BORDER="3" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" STYLE="ROUNDED" COLOR="BLUE4">
<TR><TD BGCOLOR="BLUE4"><FONT COLOR="WHITE">Aristotle's Function Argument</FONT></TD></TR>
<TR><TD>Step 1</TD></TR>
<TR><TD>Step 2</TD></TR>
<TR><TD>Step 3</TD></TR>
</TABLE>>, shape = plaintext]
```

### Example 2

```
#Varieties_of_Utilitarianism
{{default}}
-* Varieties of Utilitarianism
+ Variety 1
+ Variety 2
+ Variety 3
```
produces the following pure graphviz syntax:
```
Varieties_of_Utilitarianism [label = <
<TABLE ALIGN="LEFT" BORDER="3" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" STYLE="ROUNDED" COLOR="BLUE4">
<TR><TD BGCOLOR="BLUE4"><FONT COLOR="WHITE">Varieties of Utilitarianism</FONT></TD></TR>
<TR><TD>Variety 1</TD><TD>Variety 2</TD><TD>Variety 3</TD></TR>>
</TABLE>>, shape = plaintext]
```

### Example 3

```
#Aristotles_Argument_with_Comments 
{{default}}
-* Aristotle's Argument
- Step 1
 - Comment on step 1
- Step 2
 - Comment on step 2
- Step 3
 - Comment on step 3
```
produces the following pure graphviz syntax:
```
Aristotles_Argument_with_Comments [label = <
<TABLE ALIGN="LEFT" BORDER="3" CELLBORDER="1" CELLSPACING="0" CELLPADDING="4" STYLE="ROUNDED" COLOR="BLUE4">
<TR><TD BGCOLOR="BLUE4"><FONT COLOR="WHITE">Aristotle's Argument</FONT></TD></TR>
<TR><TD>Step 1</TD><TD>Comment on Step 1</TD></TR>
<TR><TD>Step 2</TD><TD>Comment on Step 2</TD></TR>
<TR><TD>Step 3</TD><TD>Comment on Step 3</TD></TR>>
</TABLE>>, shape = plaintext]
```

## TODO

- (bug) extra whitespace on RHS of nodes. (Maybe Linux-only?)
- (bug) rounded corners of boxes also have little points.
- make the calculation of width/height-sharing match the specification (see wiki). i.e. 'generations' (rather than items) share width equally. Allows to differentiate between 'parent-child-grandchild' (third-third-third) and 'parent-(two children)' (half-quarter-quarter).
- make the above work for rack as well as stack.
- allow for various outputs (especially stopping the process at SVG stage for those who don't want inkscape/pdf)
