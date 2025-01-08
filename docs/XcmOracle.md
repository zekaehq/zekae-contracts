# XCM Oracle

## Logs

```shell
[⠊] Compiling...
No files changed, compilation skipped

Ran 4 tests for test/XcmOracle.t.sol:XcmOracleTest
[PASS] test_CurrencyIdOfNativeEth() (gas: 10904)
Traces:
  [10904] XcmOracleTest::test_CurrencyIdOfNativeEth()
    ├─ [2696] XcmOracle::getCurrencyIdByAssetAddress(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) [staticcall]
    │   └─ ← [Return] 0x0001
    ├─ [0] VM::assertEq(0x0001000000000000000000000000000000000000000000000000000000000000, 0x0001000000000000000000000000000000000000000000000000000000000000) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_GetTokenByVToken() (gas: 17777)
Traces:
  [17777] XcmOracleTest::test_GetTokenByVToken()
    ├─ [9685] XcmOracle::getTokenByVToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 100) [staticcall]
    │   └─ ← [Return] 140
    ├─ [0] VM::assertEq(140, 140) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_GetVTokenByToken() (gas: 17899)
Traces:
  [17899] XcmOracleTest::test_GetVTokenByToken()
    ├─ [9739] XcmOracle::getVTokenByToken(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, 140) [staticcall]
    │   └─ ← [Return] 100
    ├─ [0] VM::assertEq(100, 100) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_OwnerXcmOracle() (gas: 10575)
Traces:
  [10575] XcmOracleTest::test_OwnerXcmOracle()
    ├─ [2299] XcmOracle::owner() [staticcall]
    │   └─ ← [Return] ECRecover: [0x0000000000000000000000000000000000000001]
    ├─ [0] VM::assertEq(ECRecover: [0x0000000000000000000000000000000000000001], ECRecover: [0x0000000000000000000000000000000000000001]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

Suite result: ok. 4 passed; 0 failed; 0 skipped; finished in 10.12ms (9.33ms CPU time)
```