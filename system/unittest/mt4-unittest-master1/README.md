mt4-unittest
===============
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/femtotrader/mt4-unittest?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![status](https://sourcegraph.com/api/repos/github.com/femtotrader/mt4-unittest/.badges/status.png)](https://sourcegraph.com/github.com/femtotrader/mt4-unittest)

Description
-------------

This is a unit testing library for MetaTrader 4.

Requirements
-------------

MetaTrader 4, which supports MQL 5.
Some knowledges about MQL, unit testing and test driven development.
* http://en.wikipedia.org/wiki/Unit_testing
* http://fr.wikipedia.org/wiki/Test_Driven_Development

Installation
--------------
1. Git clone this repository
2. Copy [``MQL4/Include/UnitTest.mqh``](https://github.com/femtotrader/mt4-unittest/blob/master/MQL4/Include/UnitTest.mqh) and also [``MQL4/Include/UnitTest_config.mqh``](https://github.com/femtotrader/mt4-unittest/blob/master/MQL4/Include/UnitTest_config.mqh) to ``%APPDATA%/MetaQuotes/Terminal/<ID>/MQL4/Include``
3. Copy [``MQL4/Experts/test_unittest.mq4``](https://github.com/femtotrader/mt4-unittest/blob/master/MQL4/Experts/test_unittest.mq4) to ``%APPDATA%/MetaQuotes/Terminal/<ID>/MQL4/Experts``
4. Enable AutoTrading ![AutoTrading](https://raw.githubusercontent.com/femtotrader/mt4-unittest/master/screenshots/autotrading_enabled.png)
5. Drag and drop expert advisor ``test_unittest.mq4`` to a chart ![EA_running](https://raw.githubusercontent.com/femtotrader/mt4-unittest/master/screenshots/ea_attached.png)
6. See top left comment message. You will get something like
![comment_summary_ok](https://raw.githubusercontent.com/femtotrader/mt4-unittest/master/screenshots/comment_summary_ok.png) if unit test is passing fine or, if unit test fails:  ![comment_summary_fail](https://raw.githubusercontent.com/femtotrader/mt4-unittest/master/screenshots/comment_summary_fail.png)
7. Have a look at Experts tab. You should get log message with either "OK" or "***FAIL***" for the whole unit test but also for each test case (with statistics for each asserts)
![ExpertsTab](https://raw.githubusercontent.com/femtotrader/mt4-unittest/master/screenshots/experts_tab.png)
8. Modify `test_unittest.mq4` to test your own MQL code

Experts tab log messages sample
-------------------------------
```
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: initialized
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     OK     - Total: 7, Success: 7 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: asserts: Total: 9, Success: 9 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: ================
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: UnitTest summary
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::testGetMAArray_shoudReturnCoupleOfSMA -     OK     - Total: 2, Success: 2 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::testGetMAArray_shoudReturnCoupleOfSMA - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::testGetMAArray_shoudReturnCoupleOfSMA -     OK     - MA array must contains a couple of SMA
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::testGetMA_shoudReturnSMA - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::testGetMA_shoudReturnSMA -     OK     - Total: 1, Success: 1 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::testGetMA_shoudReturnSMA - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::testGetMA_shoudReturnSMA -     OK     - MA must be SMA and 3 bars shifted
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_05_float_assertEquals_succeed - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_05_float_assertEquals_succeed -     OK     - Total: 1, Success: 1 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_05_float_assertEquals_succeed - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_05_float_assertEquals_succeed -     OK     - assertEquals with 2 floats should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_04_integers_long_assertEquals_succeed - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_04_integers_long_assertEquals_succeed -     OK     - Total: 1, Success: 1 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_04_integers_long_assertEquals_succeed - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_04_integers_long_assertEquals_succeed -     OK     - assertEquals with 2 integers should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_03_integers_int_assertEquals_succeed - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_03_integers_int_assertEquals_succeed -     OK     - Total: 1, Success: 1 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_03_integers_int_assertEquals_succeed - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_03_integers_int_assertEquals_succeed -     OK     - assertEquals with 2 integers should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_02_bool_assertFalse_succeed - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_02_bool_assertFalse_succeed -     OK     - Total: 1, Success: 1 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_02_bool_assertFalse_succeed - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_02_bool_assertFalse_succeed -     OK     - assertFalse should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_01_bool_assertTrue_succeed - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_01_bool_assertTrue_succeed -     OK     - Total: 2, Success: 2 (100.00%), Failure: 0 (0.00%)
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   MyUnitTest::test_01_bool_assertTrue_succeed - endTestCase
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_01_bool_assertTrue_succeed -     OK     - assertTrue should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:     MyUnitTest::test_01_bool_assertTrue_succeed -     OK     - assertTrue should succeed
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:    - Running new test case
2014.06.20 17:43:02.055	test_unittest EURUSD,M15:   initTestCase before every test
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: ================
2014.06.20 17:43:02.055	test_unittest EURUSD,M15: UnitTest - start
2014.06.20 17:43:02.049	Expert test_unittest EURUSD,M15: loaded successfully
```
