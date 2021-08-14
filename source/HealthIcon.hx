package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function changeCharacter(char:String){
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		animation.add('banana', [0, 1], 0, false);
		if(animation.getByName(char)!=null)
			animation.play('banana');
		else
			animation.play("face");
	}
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		flipX=isPlayer;
		changeCharacter(char);

		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
