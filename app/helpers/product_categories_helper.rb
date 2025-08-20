module ProductCategoriesHelper
  # Convert the nested hash structure provided by the ancestry gem into a flat array of arrays
  # where each inner array contains the following, specific to each element of the tree structure:
  #   category.name, category.id, depth

  #   [["Adhesives", 93, 0],
  #    ["Carving", 94, 0],
  #    ["Chisels", 95, 0],
  #    ["Drilling", 96, 0],
  #     ...]
  #   # This format is needed for form selection helper (in the new/edit form).
  def category_tree_reformat(categories, depth = 0)
    categories.flat_map do |category, children|
      # create flat label
      [ [ category.name, category.id, depth ] ] +
          category_tree_reformat(children, depth + 1) # recurse
    end
  end
end
