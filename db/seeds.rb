# This file dynamically loads and runs a seed file located at db/seeds/<environment>.rb
#
load(Rails.root.join("db", "seeds", "#{Rails.env.downcase}", "#{Rails.env.downcase}.rb"))
