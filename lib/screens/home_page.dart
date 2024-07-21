import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_exemple/models/user.dart';
import 'package:flutter_riverpod_exemple/poviders/data_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userListProvider = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riverpod Exemple"),
      ),
      body: userListProvider.when(
        data: (data) {
          final List<User> userList = data.map((e) => e).toList();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (_, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Card(
                        elevation: 4,
                        color: Colors.blue,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(
                            userList[index].firstName.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            userList[index].lastName.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: CircleAvatar(
                            backgroundImage:
                                NetworkImage(userList[index].avatar.toString()),
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: userList.length,
                  shrinkWrap: true,
                ),
              ),
            ],
          );
        },
        error: (err, stack) => const Text("Not Found"),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
