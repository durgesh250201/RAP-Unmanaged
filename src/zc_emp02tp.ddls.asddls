@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View forEmp'
@ObjectModel.semanticKey: [ 'EID' ]
@Search.searchable: true
@ObjectModel.usageType:{
                    serviceQuality: #X, 
                    sizeCategory: #S, 
                    dataClass: #MIXED
}
@UI:{ headerInfo: {
               typeName: 'Employee Database', 
               typeNamePlural: 'Employee Database', title: {
                                                         type: #STANDARD,
                                                         value: 'EID'
}
} 
}
define root view entity ZC_Emp02TP
  provider contract transactional_query
  as projection on ZR_Emp02TP as Emp
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.90
  key EID,
      Fname,
      Lname,
      Gender,
      Dept,
      Status,
      Doj,
      Dol,
      Salary,
      Currency,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      _Skill : redirected to composition child ZC_Skill01TP

}
