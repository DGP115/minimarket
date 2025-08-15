# Clear existing categories if needed
# ProductCategory.delete_all # ⚠️ Only if you want to reset the hierarchy
# ProductCategory.destroy_all also works, but delete_all skips callbacks

# Helper method to create categories recursively
def create_category(name:, parent: nil, orderindex: 1)
  if parent
    parent.children.find_or_create_by!(name: name, orderindex: orderindex)
  else
    ProductCategory.find_or_create_by!(name: name, orderindex: orderindex)
  end
end

# Top-level categories
tools    = create_category(name: "Tools", orderindex: 1)
hardware = create_category(name: "Hardware", orderindex: 2)
home     = create_category(name: "Home", orderindex: 3)
kitchen  = create_category(name: "Kitchen", orderindex: 4)
garden   = create_category(name: "Garden", orderindex: 5)
gifts    = create_category(name: "Gifts", orderindex: 6)

# Tools subcategories
adhesives = create_category(name: "Adhesives", parent: tools)
carving   = create_category(name: "Carving", parent: tools)
chisels   = create_category(name: "Chisels", parent: tools)
drilling  = create_category(name: "Drilling", parent: tools)
electrical = create_category(name: "Electrical", parent: tools)
fasteners  = create_category(name: "Fasteners", parent: tools)
saws       = create_category(name: "Saws", parent: tools)
routing    = create_category(name: "Routing", parent: tools)
turning   = create_category(name: "Turning", parent: tools)

# Drilling subcategories
create_category(name: "Drill Sets", parent: drilling)
create_category(name: "Drill Accessories", parent: drilling)

# Drill Bits sub-subcategories
drill_bits  = create_category(name: "Drill Bits", parent: drilling)
create_category(name: "Twist & Brad Points", parent: drill_bits)
create_category(name: "Plug Cutters", parent: drill_bits)
create_category(name: "Countersink/bores", parent: drill_bits)

# Saws subcategories
create_category(name: "Band Saws", parent: saws)
create_category(name: "Circular Saws", parent: saws)
create_category(name: "Jigsaws", parent: saws)
create_category(name: "Reciprocating Saws", parent: saws)
create_category(name: "Table Saws", parent: saws)

# Hand Saws sub-subcategories
hand_saws = create_category(name: "Hand Saws", parent: saws)
create_category(name: "Back Saws", parent: hand_saws)
create_category(name: "Panel Saws", parent: hand_saws)
create_category(name: "Tenon Saws", parent: hand_saws)

# Hardware subcategories
create_category(name: "Hinges", parent: hardware)
create_category(name: "Locks", parent: hardware)
create_category(name: "Nails", parent: hardware)
create_category(name: "Screws", parent: hardware)
