module FlowchartKeywords

  TABLE_BORDER_THICKNESS = 3

  EDGE_KEYS = {
    "default" => {
      color: "blue4"
    },
    "presupposition" => {
      style: "dashed",
      color: "forestgreen"
    },
    "support" => {
      color: "forestgreen"
    },
    "external-obj" => {
      color: "red3"
    },
    "internal-obj" => {
      color: "orange"
    },
    "counter" => {
      color: "green3"
    },
    "note" => {
      style: "dotted"
    },
    "example" => {
      style: "dashed",
      color: "blue4"
    },
    "type" => {
      color: "blue4"
    },
    "question" => {
      color: "blue4"
    }
  }

  NODE_KEYS = {
    default: {
      color: "blue4",
      shape: "plaintext"
    },
    roundrect: {
      shape: "rectangle, style = rounded, penwidth = 3" # default
    },
    blue: {
      color: "blue4" # default
    },
    title: { # head of branch
      shape: "plaintext", #tripleoctagon
      style: "solid",
      penwidth: "1"
    },
    level1: {
      shape: "plaintext", # doubleoctagon
      style: "solid",
      penwidth: "1"
    },
    level2: {
      shape: "plaintext", #octagon
      style: "solid",
      penwidth: "1"
    },
    level3: {
      shape: "plaintext", #rectangle
      penwidth: "4" # for indiv philosophers
    },
    presupposition: {
      color: "forestgreen",
      style: "dashed"
    },
    support: {
      color: "forestgreen",
      style: "rounded"
    },
    external_obj: {
      color: "red3",
      style: "rounded"
    },
    internal_obj: {
      color: "orange",
      style: "rounded"
    },
    counter: {
      color: "green3",
      style: "rounded"
    },
    note: {
      style: "dotted"
    },
    example: {
      style: "dashed"
    },
    argument: {
      color: "" # this needs more notation [this is to give it the colspan/rows format]
    },
    types: {
      color: "" # this needs more notation [this is to give it the rowspan/columns format]
    }
  }
end
