package;

import Math;
import flixel.FlxG;

class Rating {
    public static function generateRank(accuracy:Float)
    {
        var ranking:String = "";

        //var stringToReturn:String = accuracy + "%" + " " rankLetter;

        //return rankLetter;

        //accuracy

        var accuracyTypes:Array<Bool> = [
            accuracy >= 99.9950, //Sick!
            accuracy >= 99.9900, //Sick!
            accuracy >= 99.980, //Sick!
            accuracy >= 99.970, //Sick!
            accuracy >= 99.950, //Sick!
            accuracy >= 99.90, //Sick!
            accuracy >= 99.80, //Sick!
            accuracy >= 99.70, //Sick!
            accuracy >= 99, //Sick!
            accuracy >= 96.50, //Sick!
            accuracy >= 93, //Sick!
            accuracy >= 90, //Sick!
            accuracy >= 89, //Good
            accuracy >= 80, //Good
            accuracy >= 70, //Meh
            accuracy >= 69, //Nice
            accuracy >= 68, //Bad
        ];

        for (i in 0...accuracyTypes.length)
        {
            var r = accuracyTypes[i];
            if (r)
            {
                switch(i)
                {
                    case 0:
                        ranking += "Sick!";
                        break;
                    case 1:
                        ranking += "Sick!";
                        break;
                    case 2:
                        ranking += "Sick!";
                        break;
                    case 3:
                        ranking += "Sick!";
                        break;
                    case 4:
                        ranking += "Sick!";
                        break;
                    case 5:
                        ranking += "Sick!";
                        break;
                    case 6:
                        ranking += "Sick!";
                        break;
                    case 7:
                        ranking += "Sick!";
                        break;
                    case 8:
                        ranking += "Sick!";
                        break;
                    case 9:
                        ranking += "Sick!";
                        break;
                    case 10:
                        ranking += "Sick!";
                        break;
                    case 11:
                        ranking += "Sick!";
                        break;
                    case 12:
                        ranking += "Good";
                        break;
                    case 13:
                        ranking += "Good";
                        break;
                    case 14:
                        ranking += "Meh";
                        break;
                    case 15:
                        ranking += "Nice";
                        break;
                    case 16:
                        ranking += "Bad";
                        break;
                    default:
                        if (accuracy == 0)
                        {
                            ranking += '?';
                        }
                        else
                        {
                            ranking += 'Shit';
                        }
                }
            }
        }

        @:access
        {
            if (PlayState.misses == 0 && PlayState.badCounter == 0 && PlayState.shitCounter == 0 && PlayState.goodCounter == 0) //perfect full combo ! !
            {
                ranking += ' (PFC)';
            }
            else if (PlayState.misses == 0 && PlayState.badCounter == 0 && PlayState.shitCounter == 0 && PlayState.goodCounter > 0) //good full combo ! !
            {
                ranking += ' (GFC)';
            }
            else if (PlayState.misses == 0) //regular full combo
            {
                ranking += ' (FC)';
            }
            else if (PlayState.misses < 10) //single digit combo breaks
            {
                ranking += ' (SDCB)';
            }
            else if (PlayState.misses > 10) //joder que manco que eres
            {
                ranking += ' (Clear)';
            }
        }
        return ranking;
    }
}