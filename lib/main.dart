import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Malchut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainApp(title: 'System Malchut'),
    );
  }
}

// 1. StatefulWidgetを継承したクラスを作る。
class MainApp extends StatefulWidget {
  //　変数定義すると、UIのところから"widget.変数名" で呼ぶことができる。
  final String title;

  const MainApp({
    super.key,
    required this.title,
  });

  // createState()　で"State"（Stateを継承したクラス）を返す
  @override
  // ignore: library_private_types_in_public_api
  _MainAppState createState() => _MainAppState();
}

// 2. StateをExtendsしたクラスを作る（上記のcreateState()で返されるクラス）
class _MainAppState extends State<MainApp> {
  // クラスのフィールドとしての状態保持
  // providerのmodelで定義しているfieldにあたる
  List<int> dices = [];
  int selectedHP = 60;
  int selectedSpeed = 6;
  int selectedPower = 8;
  int selectedDex = 4;
  int selectedInt = 2;
  int actionDice = 0;
  int attackCount = 0;
  int weaponDamege = 7;
  int damege = 0;
  int priority = 0;
  List<String> logs = [];

  bool isDefendable = false;
  bool isAvoidable = false;
  bool isActionable = false;
  bool isActionDiceRollable = true;
  bool isDamegeDiceRollable = false;

  // providerのモデルで定義していたmethodをここかく。
  List<int> rollDices(int count, int side) {
    logAction("roll $count d $side");
    var random = math.Random();
    var result = List.generate(count, (_) => random.nextInt(side) + 1);
    logAction("RollResult: $result");
    return result;
  }

  void _tapRollActionDiceButton(int count, int side) {
    setState(() {
      isActionDiceRollable = false;
      actionDice = rollDices(count, side).first;
      priority = actionDice;
    });
    logAction("ActionDice: $actionDice");
    logAction("Priority: $priority");
  }

  void _tapRollDamegeDiceButton(int count, int side) {
    setState(() {
      damege = rollDices(count, side).reduce((a, b) => a + b);
      isDamegeDiceRollable = false;
    });
    logAction("Damege: $damege");
    logReset();
    getPlayerStatus();
  }

  void changeAttackCount(int? value) {
    setState(() {
      attackCount = value!;
      priority = actionDice - attackCount;
      isActionable = priority >= 1;
      isDamegeDiceRollable = attackCount > 0;
    });
    logAction("Change Attack Count: $attackCount");
    logAction("Priority: $priority");
    logAction("isActionable: $isActionable");
  }

  void getPlayerStatus() {
    logAction("-----Player Status------");
    logAction("優先度: $priority");
    logAction("攻撃回数: $attackCount回, ダメージ: $damege");
    logAction("防御: $isDefendable, 回避: $isAvoidable");
  }

  void reset() {
    setState(() {
      logReset();
      actionDice = 0;
      attackCount = 0;
      damege = 0;
      isActionable = false;
      isDefendable = false;
      isAvoidable = false;
      isActionDiceRollable = true;
      isDamegeDiceRollable = false;
    });
  }

  void logAction(String log) {
    setState(() {
      logs.add(log);
    });
  }

  void logReset() {
    setState(() {
      logs.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    // 　UIの部分はここに書く。
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("HP: $selectedHP"),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("速度: $selectedSpeed"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("力: $selectedPower"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("器用さ: $selectedDex"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("知識: $selectedInt"),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: isActionDiceRollable
                      ? () => _tapRollActionDiceButton(1, selectedSpeed)
                      : null,
                    child: const Text('行動ダイス'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("行動ダイス： $actionDice"),
                  )
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      const Text("攻撃回数 : "),
                      DropdownButton(
                        items: List.generate(actionDice + 1, (index) => index)
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        value: attackCount,
                        onChanged: (int? value) => changeAttackCount(value),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: isDamegeDiceRollable
                          ? () =>
                            _tapRollDamegeDiceButton(attackCount, weaponDamege)
                          : null,
                        child: const Text('ダメージダイス'),
                      ),
                      Text("ダメージ：$damege")
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Column(
                  children: [
                    const Text("防御"),
                    Checkbox(
                      value: isDefendable,
                      onChanged: isActionable && !isAvoidable
                          ? (value) {
                              setState(() {
                                isDefendable = value!;
                              });
                            }
                          : null,
                    )
                  ],
                ),
                Column(
                  children: [
                    const Text("回避"),
                    Checkbox(
                      value: isAvoidable,
                      onChanged: isActionable && !isDefendable
                          ? (value) {
                              setState(() {
                                isAvoidable = value!;
                              });
                            }
                          : null,
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Text("Log $index : ${logs[index]}");
                },
              ),
            ),
            ElevatedButton(
              onPressed: reset,
              child: const Text('次のターンへ'),
            ),
          ],
        ),
      ),
    );
  }
}
