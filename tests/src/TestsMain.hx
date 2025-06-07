import utest.Runner;
import utest.ui.Report;

class TestsMain {
	public static function main():Void {
		var runner = new Runner();
		runner.addCase(new tests.GTweenTests());
		// plugins
		#if (openfl || flash)
		runner.addCase(new tests.plugins.AutoHidePluginTests());
		runner.addCase(new tests.plugins.MotionBlurPluginTests());
		#end
		runner.addCase(new tests.plugins.SnappingPluginTests());
		runner.addCase(new tests.plugins.SmartRotationPluginTests());

		Report.create(runner);

		runner.run();
	}
}