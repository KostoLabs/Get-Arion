# lib/maybe.rb

require_relative "server" # classe Semver

module Arion
  def self.version
    Semver.new("1.0.0") # à remplacer par la vraie version si besoin
  end

  def self.commit_sha
    @commit_sha ||= begin
      sha = `git rev-parse HEAD`.strip
      sha.empty? ? nil : sha
    rescue
      nil
    end
  end
end

# Alias Maybe vers Arion pour compatibilité avec les vues existantes
Maybe = Arion
