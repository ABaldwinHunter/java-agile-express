package com.express.model.domain
{
[RemoteClass(alias="com.express.service.dto.IssueDto")]
public class Issue {

   public function Issue() {
   }

   public var id : Number;

   public var version : Number;

   public var title : String;

   public var description : String;

   public var startDate : Date;

   public var endDate : Date;

   public var iteration : Iteration;

   public var responsible : User;

}
}