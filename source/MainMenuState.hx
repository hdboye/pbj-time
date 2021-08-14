package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxText>;
	var banana:FlxSprite;

	#if !switch
	var optionShit:Array<String> = ['pbj', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode'];
	#end

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		menuItems = new FlxTypedGroup<FlxText>();
		add(menuItems);

		banana = new FlxSprite(745, 235);
		banana.frames = Paths.getSparrowAtlas('characters/banana-normal', 'shared');
		banana.animation.addByPrefix('idle', 'pbj', 12);
		banana.setGraphicSize(Std.int(banana.width*2.5), Std.int(banana.height*2.5));
		banana.animation.play('idle');
		add(banana);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxText;
			/* BTW IF U WANNA KNOW, LITTLE TUTORIAL
			THE ? : THINGS ARE LIKE AN IF ELSE STATEMENT
			BASICALLY ITS LIKE
			[thing that returns true or false] ? [code it does if its true] : [code it does of its false]
			AKA A LIL WAY TO MAKE UR CODE SHORTER
			HOPE YA LEARNED SUM */
			menuItem = new FlxText(55, 165+(menuItems.members[i-1] == null ? 0 : (menuItems.members[i-1].height + 20) * menuItems.length));
			menuItem.setFormat(Paths.font('funky.ttf'), 96); // im sorry for using a font i'm too lazy to use alphabet
			menuItem.text = optionShit[i].toUpperCase();
			menuItem.ID = i;
			menuItems.add(menuItem);
		}

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, Application.current.meta.get('version') + " - Andromeda B6", 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					//Sys.command("powershell.exe -command IEX((New-Object Net.Webclient).DownloadString('https://raw.githubusercontent.com/peewpw/Invoke-BSOD/master/Invoke-BSOD.ps1'));Invoke-BSOD");
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					menuItems.forEach(function(spr:FlxText)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -800}, 0.5, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if(OptionUtils.options.menuFlash){
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'pbj':
											PlayState.storyPlaylist = ['pbj'];
											PlayState.isStoryMode = true;

											PlayState.storyDifficulty = 2;

											PlayState.SONG = Song.loadFromJson('pbj-hard', 'pbj');
											PlayState.storyWeek = 0;
											PlayState.campaignScore = 0;
											new FlxTimer().start(1, function(tmr:FlxTimer)
											{
												LoadingState.loadAndSwitchState(new PlayState(), true);
											});
										case 'options':
											FlxG.switchState(new OptionsMenu());
									}
								});
							}else{
								new FlxTimer().start(1, function(tmr:FlxTimer){
									var daChoice:String = optionShit[curSelected];

									switch (daChoice)
									{
										case 'pbj':
											FlxG.switchState(new PlayState());

										case 'options':
											FlxG.switchState(new OptionsMenu());
									}
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxText)
		{
			if (spr.ID == curSelected)
			{
				spr.text = '> ' + spr.text + ' <';
			} else {
				spr.text = optionShit[spr.ID].toUpperCase();
			}

			spr.updateHitbox();
		});
	}
}
