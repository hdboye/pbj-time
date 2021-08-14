package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import sys.io.File;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var offsetNames:Array<String>=[];
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'banana';
	public var holding:Bool=false;
	public var disabledDance:Bool = false;

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?banana:String = 'normal', ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'banana':
				var tex = Paths.getSparrowAtlas('characters/banana-' + banana,'shared');
				frames = tex;
				animation.addByPrefix('idle', 'pbj', 12, true); // the only thing for now lmao

				loadOffsets();
				playAnim('idle');

				flipX = true;
		default:
			var xmlData:String = '';
			/*if(Cache.xmlData[curCharacter]!=null){
				xmlData=Cache.xmlData[curCharacter];
			}else{
				xmlData=File.getContent("assets/shared/images/characters/"+curCharacter+".xml");
				Cache.xmlData[curCharacter]=xmlData;
			}
			var bitmapData:BitmapData;
			if(FlxG.bitmap.get(curCharacter + "CharFrames")!=null){
				bitmapData = FlxG.bitmap.get(curCharacter + "CharFrames").bitmap;
			}else{
				bitmapData = BitmapData.fromFile("assets/shared/images/characters/"+curCharacter+".png");
				FlxG.bitmap.add(bitmapData,true,curCharacter+"CharFrames");
			}*/

			if(Cache.charFrames[curCharacter]!=null){
				frames=Cache.charFrames[curCharacter];
			}else{
				frames = FlxAtlasFrames.fromSparrow(BitmapData.fromFile("assets/shared/images/characters/"+curCharacter+".png"),File.getContent("assets/shared/images/characters/"+curCharacter+".xml"));
				Cache.charFrames[curCharacter]=frames;
			}
			FlxG.bitmap.dumpCache();

			loadAnimations();
			loadOffsets();

			if(animation.getByName("idle")!=null)
				playAnim("idle");
			else
				playAnim("danceRight");
		}


		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/* Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}else if (curCharacter.startsWith('bf')){
			var oldRight = animation.getByName('singRIGHT').frames;
			animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
			animation.getByName('singLEFT').frames = oldRight;

			// IF THEY HAVE MISS ANIMATIONS??
			if (animation.getByName('singRIGHTmiss') != null)
			{
				var oldMiss = animation.getByName('singRIGHTmiss').frames;
				animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
				animation.getByName('singLEFTmiss').frames = oldMiss;
			} */
		}

	}

	public function loadOffsets(){
		//var offsets = CoolUtil.coolTextFile(Paths.txtImages('characters/'+curCharacter+"Offsets"));
		var offsets:Array<String>;
		if(Cache.offsetData[curCharacter]!=null){
			offsets = CoolUtil.coolTextFile2(Cache.offsetData[curCharacter]);
		}else{
			var data = File.getContent("assets/shared/images/characters/"+curCharacter+"Offsets.txt");
			offsets = CoolUtil.coolTextFile2(data);
			Cache.offsetData[curCharacter] = data;
		}
		for(s in offsets){
			var stuff:Array<String> = s.split(" ");
			addOffset(stuff[0],Std.parseFloat(stuff[1]),Std.parseFloat(stuff[2]));
		}
	}

	public function loadAnimations(){
		trace("loading anims for " + curCharacter);
		try {
			//var anims = CoolUtil.coolTextFile(Paths.txtImages('characters/'+curCharacter+"Anims"));
			var anims:Array<String>;
			if(Cache.offsetData[curCharacter]!=null){
				anims = CoolUtil.coolTextFile2(Cache.animData[curCharacter]);
			}else{
				var data = File.getContent("assets/shared/images/characters/"+curCharacter+"Anims.txt");
				anims = CoolUtil.coolTextFile2(data);
				Cache.animData[curCharacter] = data;
			}
			for(s in anims){
				var stuff:Array<String> = s.split(" ");
				var type = stuff.splice(0,1)[0];
				var name = stuff.splice(0,1)[0];
				var fps = Std.parseInt(stuff.splice(0,1)[0]);
				trace(type,name,stuff.join(" "),fps);
				if(type.toLowerCase()=='prefix'){
					animation.addByPrefix(name, stuff.join(" "), fps, false);
				}else if(type.toLowerCase()=='indices'){
					var shit = stuff.join(" ");
					var indiceShit = shit.split("/")[1];
					var prefixShit = shit.split("/")[0];
					var newArray:Array<Int> = [];
					for(i in indiceShit.split(" ")){
						newArray.push(Std.parseInt(i));
					};
					animation.addByIndices(name, prefixShit, newArray, "", fps, false);
				}
			}
		} catch(e:Dynamic) {
			trace("FUCK" + e);
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if(animation.getByName('${animation.curAnim.name}Hold')!=null){
				animation.paused=false;
				if(animation.curAnim.name.startsWith("sing") && !animation.curAnim.name.endsWith("Hold") && animation.curAnim.finished){
					playAnim(animation.curAnim.name + "Hold",true);
				}
			}

			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();

				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
		if(holding)
			animation.curAnim.curFrame=0;
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && !disabledDance)
		{
			holding=false;
			if(animation.getByName("idle")!=null)
				playAnim("idle");
			else if (animation.getByName("danceRight")!=null && animation.getByName("danceLeft")!=null){
				if (!animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if(AnimName.endsWith("miss") && animation.getByName(AnimName)==null ){
			AnimName = AnimName.substring(0,AnimName.length-4);
		}

		//animation.getByName(AnimName).frameRate=animation.getByName(AnimName).frameRate;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		offsetNames.push(name);
		animOffsets[name] = [x, y];
	}
}
