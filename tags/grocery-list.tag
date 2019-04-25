<grocery-list>
  <div class="">
    <h1>Grocery List</h1>
    <form class="">
      <input ref="input" type="text" name="item" placeholder="item" onchange={ inputItem }>
      <button type="button" onclick= { add }>Add to list</button>
      <button type="button" disabled={ list.filter(onlyDone).length == 0 } onclick={ removeDone }>
			Remove{ list.filter(onlyDone).length }
		</button>
    </form>
  </div>
  <div style="margin-top:30px;"class="">
      <ul>
        <li each= { todo in list.filter(whatShow) }>
          <label class={ completed: todo.done }>
            <input type="checkbox" checked = { todo.done } onclick = { parent.toggle }>
            {todo.title}
          </label>
        </li>
      </ul>



  </div>



  <script>

    //set up database
    let database = firebase.firestore();

    let usersRef = database.collection('users');

    // let userKey = firebase.auth().currentUser.uid;
    // let groceryRef = database.doc('users/' + userKey).collection('groceryList');

    this.item = "";
    this.list = [];

    inputItem(e) {
      //user input the item
      this.item = e.currentTarget.value;
    };

  //add todo and write to db
    add(e) {
      //database write preparation
      let userKey = firebase.auth().currentUser.uid;
      let groceryRef = database.doc('users/' + userKey).collection('groceryList');
      let itemID = groceryRef.doc().id;

     if (this.item) {
      let todo = {
        title: this.item,
        done: false,
        id: itemID,
        timestamp:firebase.firestore.FieldValue.serverTimestamp()
      };
      this.list.push(todo);
      console.log(this.list);
      this.update();

      //database write
      groceryRef.doc(itemID).set({

        title: this.item,
        done: false,
        id: itemID,
        timestamp:firebase.firestore.FieldValue.serverTimestamp()

      });

      this.item = this.refs.input.value = '';
     }
     event.preventDefault();
   };

   //remove todo and delete from db
   removeDone(event) {
     let doneItems = this.list.filter(todo => todo.done);
     //database write preparation
     let userKey = firebase.auth().currentUser.uid;
     let groceryRef = database.doc('users/' + userKey).collection('groceryList');
     let itemID = groceryRef.doc().id;

			for (doneTodo of doneItems) {
				// DATABASE DELETE
				groceryRef.doc(itemID).delete();
			};

      this.list = this.list.filter(todo => !todo.done);
      this.update();

   }


    toggle(event) {
      let item = event.item.todo;
			item.done = !item.done;
      //database write preparation
      let userKey = firebase.auth().currentUser.uid;
      let groceryRef = database.doc('users/' + userKey).collection('groceryList');
      let itemID = groceryRef.doc().id;
      console.log(itemID);
			groceryRef.doc(itemID).update({
				done: item.done
			});
			return true;
    };

    whatShow(item) {
			return !item.hidden;
		}

    onlyDone(item) {
			return item.done;
		}

    // LIFECYCLE EVENTS ---------------------------------------

		let stopListening;

		this.on('mount', () => {
      //database write preparation
      let userKey = firebase.auth().currentUser.uid;
      let groceryRef = database.doc('users/' + userKey).collection('groceryList');
			// DATABASE READ LIVE
			stopListening = groceryRef.orderBy('timestamp', 'desc').onSnapshot(snapshot => {
				this.list = snapshot.docs.map(doc => doc.data());
				this.update();
			});
		});

		this.on('unmount', () => {
			stopListening();
		});


  </script>

  <style>
   .completed {
     text-decoration: line-through;
     color:#ccc;
   }

  </style>
</grocery-list>
