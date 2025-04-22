@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forEmp'
define root view entity ZI_Emp02TP
  provider contract TRANSACTIONAL_INTERFACE
  as projection on ZR_Emp02TP as Emp
{
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
  _Skill : redirected to composition child ZI_Skill01TP
  
}
