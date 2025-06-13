# config/initializers/maybe_alias.rb

# Crée Maybe comme alias d'Arion si ce n'est pas déjà défini
Maybe = Arion unless defined?(Maybe)
