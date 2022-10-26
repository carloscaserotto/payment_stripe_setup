class Orders::ArticlesCreator
    def initialize(title, body)
        @title=title
        @body=body
    end
    def create
        @article = Article.new(title: @title, body: @body)    
    end

  
end