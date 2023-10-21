
// //! تایپ رو دستی میدم 


// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:contacts_service/contacts_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:p_4/src/view/data/model/message_model.dart';
import 'package:p_4/src/view/data/model/user_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/common/permission_service.dart';
import '../../domain/repo/chat_repo_header.dart';


  //* < state = String ,data= List<Model>>
  
class ChatRepoBody extends ChatRepoHeader{
  PermissionService permission = PermissionService();
final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<Map<String,List<MessageModel>>> getExistConversition() async {
    String curretnUserId = supabase.auth.currentSession!.user.id;
    try{
      final List<MessageModel> res = await supabase.from('chat')
        .select<PostgrestList>()
        .eq('senderID', curretnUserId)
        .not('receiverID', 'eq', 'groups').
        then((value) => value.map((e) => MessageModel.fromJson(e, curretnUserId)).toList());


      List<MessageModel> data = [];
      Set<String> set = res.map((e) => e.receiverID).toSet();
      for (var e in set) { 
        data.add(res.firstWhere((i) => i.receiverID == e)); 
      }
      return { 'ok' : data };
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return {e.toString() : []};}
    on SupabaseRealtimeError catch(e){log('in Group $e');return {e.toString() : []};}
    on Exception catch(e){return { e.toString() : []};}
    catch(e){
      return { e.toString() : []};
    }
  }

  @override
  Future<Map<String,List<UserModel>>> getExistConversitonImage()async{
    try{
      List<UserModel> data = [];
      Map<String,List<MessageModel>> getExistConverstion = await getExistConversition();
      final List<UserModel> res = await supabase.from('user').select<PostgrestList>().then((value) => value.map((e) => UserModel.fromJson(e)).toList());

      for(var userModel in res){
        for(var i in getExistConverstion.values){ 
          for (var element in i) {
            if(userModel.uid == element.receiverID) data.add(userModel);
          }
        }
      }
      return {'ok':data};

    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return {e.toString():[]};}
    catch(e){
      return {e.toString(): []}; 
    }
  }

  @override
  Future<String> sendMessage(String message,String receiverID) async {
    String curretnUserID = supabase.auth.currentUser!.id;
    try{
      List<String> ids = [curretnUserID,receiverID];
      ids.sort();
      String chatRoomId = ids.join('_');
      String uid = const Uuid().v1();


      MessageModel messageModel = MessageModel.create(  
        uid,
        curretnUserID, 
        receiverID, 
        message,
        chatRoomId ,);
      
      await supabase.from('chat').insert(messageModel.toMap());
      return 'ok';
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return e.toString();}
    on SupabaseRealtimeError catch(e){return e.toString();}
    catch(e){return e.toString();}
    

  }
  
  @override
  Future<String> deleteMessagee(String uid)async{
    try{
      await supabase.from('chat').delete().eq('uid', uid);
      return 'ok';
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return e.toString();}
    on SupabaseRealtimeError catch(e){return e.toString();}
    catch(e){return e.toString();}
  }

  @override
  Map<String,Stream<List<MessageModel>>> getMessage(String receiverID){
    try{

        String curretnUserID = supabase.auth.currentUser!.id;
        List<String> ids = [curretnUserID,receiverID];
        ids.sort();
        String chatRoomId = ids.join('_');
        
        Stream<List<MessageModel>> messagesStream =
          supabase
            .from('chat')
            .stream(primaryKey: ['id'])
            .order('timestamp')
            .eq('chatRoomId', chatRoomId)
            .map((event) => event.map((e) => MessageModel.fromJson(e,curretnUserID)).toList());
        
      return {'ok':messagesStream};
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return {e.toString():const Stream.empty()};}
    on SupabaseRealtimeError catch(e){return {e.toString():const Stream.empty()};}
    catch(e){return {e.toString() : const Stream.empty()};}
    

  }

  @override
  Future<void> isOnlineStatus(bool status)async{
    final user = supabase.auth.currentSession!.user.id;
    await supabase.from('user').update({'inOnline':status}).eq('uid', user);
  }
  
  @override
  Stream<List<UserModel>>? getUserStatus(){
    String currentUserId = supabase.auth.currentSession!.user.id;
    return supabase
      .from('user')
      .stream(primaryKey: ['id'])
      .order('timestamp')
      .eq('uid',currentUserId)
      .map((event) => event.map((e) =>UserModel.fromJson(e)).toList());
  }

  @override
  Future<String> sendLocationMessage(String message,String receiverID,)async{
    String curretnUserID = supabase.auth.currentUser!.id;
    try{
      List<String> ids = [curretnUserID,receiverID];
      ids.sort();
      String chatRoomId = ids.join('_');
      String uid = const Uuid().v1();

      MessageModel messageModel = MessageModel(  
        uid: uid,
        senderID: curretnUserID, 
        receiverID: receiverID, 
        messsage: message, 
        chatRoomID:chatRoomId,
        type: 'location', 
        timestamp: DateFormat.yMMMEd().format(DateTime.now()), 
        fileType: 'location', 
        markAsRead: false, 
        isMine: true,);
      
      await supabase.from('chat').insert(messageModel.toMap());
      return 'ok';
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return e.toString();}
    on SupabaseRealtimeError catch(e){return e.toString();}
    catch(e){return e.toString();}
    
  }

  @override
  Future<Map<String,List<UserModel>>> allUsers()async{
    try{
      // await Permission.contacts.request();
      await permission.req([Permission.contacts]);

      //!data from table
      final List<UserModel> res = await supabase.from('user').select<PostgrestList>().not('uid', 'eq', supabase.auth.currentUser!.id).then((value) => value.map((e) => UserModel.fromJson(e)).toList());
      
      //! contacts from device
      List<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);

      List<UserModel> data = [];

      for(var user in res){
        
        String phoneNumberUser = user.phone!.substring(1);

        for(var contact in contacts){
          
          contact.phones?.toSet().forEach((phone) {
            String? value = phone.value;
            if(value!.startsWith('+98')){
              phoneNumberUser == value.substring(3) ? data.add(user) : null;
            }
            else if(value.startsWith('09')){
              phoneNumberUser == value.substring(1) ? data.add(user) : null;
            }
          });

        }
      }
      return {'ok':data};
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return {e.toString():[]};}
    on SupabaseRealtimeError catch(e){return {e.toString():[]};}
    catch(e){return {e.toString():[]};}
    
  }

  @override
  Future<Map<String,List<MessageModel?>>> getImageMessage(String receiverID)async{
    try{
        String curretnUserID = supabase.auth.currentUser!.id;
        List<String> ids = [curretnUserID,receiverID];
        ids.sort();
        String chatRoomId = ids.join('_');
        
        List<MessageModel> images = [];

      await supabase
            .from('chat')
            .select<PostgrestList>()
            .eq('chatRoomId', chatRoomId)
            .then((value) => value.map((e){MessageModel data = MessageModel.fromJson(e, curretnUserID);if(data.type.contains('image'))images.add(data);}).toList());
        
        
      return {'ok':images};
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return {e.toString():[]};}
    on SupabaseRealtimeError catch(e){return {e.toString():[]};}
    catch(e){return {e.toString():[]};}
    
    

  }

  @override
  Future<Map<String,List<MessageModel?>>> getFileMessage(String receiverID)async{
    try{
      String curretnUserID = supabase.auth.currentUser!.id;
      List<String> ids = [curretnUserID,receiverID];
      ids.sort();
      String chatRoomId = ids.join('_');
      
      List<MessageModel> images = [];

    await supabase
          .from('chat')
          .select<PostgrestList>()
          .eq('chatRoomId', chatRoomId)
          .then((value) => value.map((e){
            MessageModel data = MessageModel.fromJson(e, curretnUserID);
            if(data.type.contains('file'))images.add(data);
          }).toList());
      
      
    return {'ok':images};
    }
    on PostgrestException catch(e){return {e.toString():[]};}
    on SupabaseRealtimeError catch(e){return {e.toString():[]};}
    catch(e){return {e.toString():[]};}
    
    

  }

  @override
  Future<Map<List<MessageModel>,List<int>>> searching(String receiverID,String search,)async{

    String curretnUserID = supabase.auth.currentUser!.id;
    List<String> ids = [curretnUserID,receiverID];
    ids.sort();
    String chatRoomId = ids.join('_');

    List<MessageModel> searchingData = [];
    List<int> searchingIndex = [];

    
    List<MessageModel> messages = await supabase.from('chat').select<PostgrestList>().eq('chatRoomId', chatRoomId).then((event) => event.map((e) => MessageModel.fromJson(e,curretnUserID)).toList());
    List<MessageModel> reverseMessage = messages.reversed.toList();

    // for(var model in reverseMessage){
    //   if(model.messsage.toUpperCase().contains(search.toUpperCase())){
    //     searchingData.add(model);
    //     searchingIndex.add(value)
    //   };
    // }

    for(int i = 0; i < reverseMessage.length; i++){
      MessageModel model = reverseMessage[i];
      if(model.messsage.toUpperCase().contains(search.toUpperCase())){
        searchingData.add(model);
        searchingIndex.add(i);
      }
    }

    return {searchingData:searchingIndex};
  }

  @override
  Future<String> deleteGroup(String groupUid)async{
    try{
      await supabase.from('user').delete().eq('uid', groupUid);
      return 'ok';
    }
    on PostgrestException catch(e){log('in Group Created Metod $e');return e.toString();}
    on SupabaseRealtimeError catch(e){return e.toString();}
    catch(e){return e.toString();}
  }

  @override
  String? currentUserId() =>  supabase.auth.currentUser!.id;
}
