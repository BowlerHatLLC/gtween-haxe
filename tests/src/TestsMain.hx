import utest.Runner;
import utest.ui.Report;

class TestsMain {
	public static function main():Void {
		var runner = new Runner();
		runner.addCase(new tests.GTweenTests());
		// plugins
		#if (openfl || flash)
		runner.addCase(new tests.plugins.MotionBlurPluginTests());
		#end

		Report.create(runner);

		runner.run();
	}
}