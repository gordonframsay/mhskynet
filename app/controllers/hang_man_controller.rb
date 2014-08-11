class HangManController < ApplicationController

 def index
  if request.post?
   game = HangManGame.new(:phrase => params[:phrase].upcase, :letters_guessed => "")
   game.save!
   flash[:notice] = "New Game Started!"
   redirect_to '/hang_man/game/'+game.id.to_s
  end
 end

 def game
   if params[:id]
    @game = HangManGame.find(params[:id])
    if params[:guess]
#render :inline => "bam" and return false
     if (@game.letters_guessed.match(params[:guess].upcase) || (params[:guess].length != 1) || ! ('A'..'Z').to_a.include?(params[:guess].upcase))
      @error = "Bad guess.  Only one letter at a time, or already guessed."
     else
      @game.letters_guessed += params[:guess].upcase
      @game.save!
     end
     @letters_not_found = @game.letters_guessed.split('').reject {|x| ! ('A'..'Z').to_a.include?(x) } - @game.phrase.split('')
     render :action => "game_play", :layout => false
    else
    end
   end
 end

end