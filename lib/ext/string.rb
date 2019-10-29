class String
  def numbers_only
    self.delete('^0-9')
  end
end
