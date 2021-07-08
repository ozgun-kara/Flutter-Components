import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget 
{ 
  @override
  Widget build(BuildContext context) 
  {
	return new MaterialApp(
	
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Users'),
    );
  }
}

class MyHomePage extends StatefulWidget 
{

  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  Future<List<User>> _getUsers() async 
  {
    var data = await http.get("http://www.json-generator.com/api/json/get/bQlOGsODVK?indent=2");
    var jsonData = json.decode(data.body);

    List<User> users = [];
	
		  for (var u in jsonData) 
		  {
			User user =
			User(u["index"], u["about"], u["name"], u["email"], u["picture"]);
      
			for (int i = 0; i < 50; i++)
			{
				users.add(user);
			}
		  }
	
    return users;
  }

  @override
  Widget build(BuildContext context) 
  {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
	  
      body: SafeArea(
        child: Center(
          child: Container(
            child: FutureBuilder(
              future: _getUsers(),
              builder: (BuildContext context, AsyncSnapshot snapshot) 
			  {
                print(snapshot.data);
                if (snapshot.data == null) {
                  // return Container(child: Center(child: Text("Loading...")));
                  return Container(
                      child: Center(
                          child: CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.lightBlue))));
                } else 
				
				{
                  return ListView.separated(
                    itemCount: snapshot.data.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
                      thickness: 3,
                      color: Colors.black,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data[index].picture),
                        ),
						
                        title: Text(snapshot.data[index].name),
                        subtitle: Text(snapshot.data[index].email),
                        trailing: Text('${index + 1}',
                            style: TextStyle(
                                fontFamily: 'BlackOpsOne',
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                        onTap: () 
						{
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) =>
                                      DetailPage(snapshot.data[index])));
                        },
						
                      );
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget 
{

  final User user;
  DetailPage(this.user);


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
        appBar: AppBar(
      title: Text(user.name),
    ));
  }

}


class User 
{
  final String picture;
  final String about;
  final String name;
  final int index;
  final String email;

  User(this.index, this.about, this.name, this.email, this.picture);
}




