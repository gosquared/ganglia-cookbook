actions :create,
        :remove

attribute :name,  :kind_of => String
attribute :type,  :kind_of => String, :default => "standard"
attribute :items, :kind_of => Array
