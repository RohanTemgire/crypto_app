import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import '../widgets/buttons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  int amount = 0;
  // bool isupdating = false;
  var myData;

  final myAddress = '0xA2D0C4047De23257C37D0e12E95bd05c917552c2';

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        'https://rinkeby.infura.io/v3/7ca513d2d19f4fcfa812f4f05bf37889',
        httpClient);
    getBalance(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString('assets/abi.json');
    String contractAddress = '0x6fb15eE29Bf35fc51D960709A8f312da311fD009';
    final contract = DeployedContract(ContractAbi.fromJson(abi, 'RohCoin'),
        EthereumAddress.fromHex(contractAddress));

    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  getBalance(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    setState(() {
      data = false;
    });
    List<dynamic> result = await query('getBalance', []);
    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "36c2b151a0b8256b3acb8c803e078c2ff6d9098e00fb6780bc88623ef8d93217");

    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
          contract: contract, function: ethFunction, parameters: args),
    );

    return result;
  }

  Future<String> deposit() async {
    var bigAmount = BigInt.from(amount);
    var response = await submit('depositBalance', [bigAmount]);

    print('deposited');
    return response;
  }

  Future<String> withdraw() async {
    var bigAmount = BigInt.from(amount);
    var response = await submit('withdrawBalance', [bigAmount]);

    print('withdrawm');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(224, 224, 224, 1),
      body: Container(
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            Positioned(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(color: Colors.blue),
                child: Center(
                  child: Text(
                    'Crypto Coin',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.width * 0.10,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.22,
              left: MediaQuery.of(context).size.width * 0.06,
              right: MediaQuery.of(context).size.width * 0.06,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width * 0.8,
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Balance',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                            color: Colors.black54,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: data
                          ? Text(
                              '\$$myData',
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.12,
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.50),
              padding: const EdgeInsets.all(10),
              child: TextFormField(
                onChanged: (value) {
                  amount = int.parse(value);
                },
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Enter Amount',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(width: 2, color: Colors.blue),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Buttons(
                          buttonText: 'Deposit',
                          color: Colors.green,
                          icon: const Icon(
                            Icons.call_made_rounded,
                            color: Colors.white,
                          ),
                          function: () {
                            print('deposit');
                            print(amount);
                            deposit();
                          }),
                      Buttons(
                        buttonText: 'Withdraw',
                        color: Colors.red,
                        icon: const Icon(
                          Icons.call_received_rounded,
                          color: Colors.white,
                        ),
                        function: () {
                          print('Withdraw');
                          print(amount);
                          withdraw();
                        },
                      ),
                      Buttons(
                          buttonText: 'Refresh',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          function: () {
                            getBalance(myAddress);
                            print('Refresh');
                            print(amount);
                          }),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
