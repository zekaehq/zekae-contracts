# Base SLPX

## Logs

```shell
Ran 6 tests for test/BaseSlpx.t.sol:BaseSlpxTest
[PASS] test_GatewayExchangeRate() (gas: 15259)
Traces:
  [15259] BaseSlpxTest::test_GatewayExchangeRate()
    ├─ [2742] Gateway::quoteExchangeRate(vETH: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 2030, 1000000 [1e6]) [staticcall]
    │   └─ ← [Return] 1400000000000000000 [1.4e18]
    ├─ [0] VM::assertEq(1400000000000000000 [1.4e18], 1400000000000000000 [1.4e18]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_GatewaySendTokenFee() (gas: 15195)
Traces:
  [15195] BaseSlpxTest::test_GatewaySendTokenFee()
    ├─ [2743] Gateway::quoteSendTokenFee(vETH: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 2030, 1000000 [1e6]) [staticcall]
    │   └─ ← [Return] 1000000 [1e6]
    ├─ [0] VM::assertEq(1000000 [1e6], 1000000 [1e6]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_Mint() (gas: 85188)
Traces:
  [85188] BaseSlpxTest::test_Mint()
    ├─ [0] VM::startPrank(SHA-256: [0x0000000000000000000000000000000000000002])
    │   └─ ← [Return]
    ├─ [66488] BaseSlpx::mint{value: 14000000000000000000}()
    │   ├─ [2742] Gateway::quoteExchangeRate(vETH: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], 2030, 1000000 [1e6]) [staticcall]
    │   │   └─ ← [Return] 1400000000000000000 [1.4e18]
    │   ├─ [49014] vETH::mint(SHA-256: [0x0000000000000000000000000000000000000002], 10000000000000000000 [1e19])
    │   │   ├─ emit Transfer(from: 0x0000000000000000000000000000000000000000, to: SHA-256: [0x0000000000000000000000000000000000000002], value: 10000000000000000000 [1e19])
    │   │   └─ ← [Stop]
    │   └─ ← [Stop]
    ├─ [0] VM::stopPrank()
    │   └─ ← [Return]
    ├─ [648] vETH::balanceOf(SHA-256: [0x0000000000000000000000000000000000000002]) [staticcall]
    │   └─ ← [Return] 10000000000000000000 [1e19]
    ├─ [0] VM::assertEq(10000000000000000000 [1e19], 10000000000000000000 [1e19]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_OwnerBaseSlpx() (gas: 10573)
Traces:
  [10573] BaseSlpxTest::test_OwnerBaseSlpx()
    ├─ [2352] BaseSlpx::owner() [staticcall]
    │   └─ ← [Return] ECRecover: [0x0000000000000000000000000000000000000001]
    ├─ [0] VM::assertEq(ECRecover: [0x0000000000000000000000000000000000000001], ECRecover: [0x0000000000000000000000000000000000000001]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_OwnerGateway() (gas: 10440)
Traces:
  [10440] BaseSlpxTest::test_OwnerGateway()
    ├─ [2311] Gateway::owner() [staticcall]
    │   └─ ← [Return] ECRecover: [0x0000000000000000000000000000000000000001]
    ├─ [0] VM::assertEq(ECRecover: [0x0000000000000000000000000000000000000001], ECRecover: [0x0000000000000000000000000000000000000001]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

[PASS] test_OwnerVeth() (gas: 12713)
Traces:
  [12713] BaseSlpxTest::test_OwnerVeth()
    ├─ [2411] vETH::owner() [staticcall]
    │   └─ ← [Return] BaseSlpx: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a]
    ├─ [0] VM::assertEq(BaseSlpx: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], BaseSlpx: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a]) [staticcall]
    │   └─ ← [Return]
    └─ ← [Stop]

Suite result: ok. 6 passed; 0 failed; 0 skipped; finished in 10.15ms (13.98ms CPU time)
```