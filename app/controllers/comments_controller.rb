class CommentsController < ApplicationController
  before_action :set_post

  def create
    comment = @post.comments.create! params.required(:comment).permit(:content)
    CommentsMailer.submitted(comment).deliver_later
    redirect_to @post
  end

  private
    def set_post
      @post = Post.find(params[:post_id])
    end
end
