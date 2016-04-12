//klasa rozszerzająca SQLStatement
package base.sql {
	import flash.data.SQLConnection;
	import flash.data.SQLStatement;
	
	public class SQLStatementEx extends SQLStatement {
	
		public function SQLStatementEx(sqlConnection: SQLConnection, itemClass: Class) {
			super();
			this.sqlConnection = sqlConnection;
			this.itemClass = itemClass;
		}
		
		//funkcja umożliwiająca wykonanie sqla w jednej linijce kodu
		public function executeSQL(strSQL: String, parameters: Array = null):void {
			this.text = strSQL;
			if (parameters != null) {
				for (var i: uint; i < parameters.length; i++) {
					this.parameters[":" + parameters[i][0]] = parameters[i][1];
				}
			}
			this.execute();
		}
	}
}