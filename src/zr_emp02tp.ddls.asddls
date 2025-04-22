@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forEmp'
define root view entity ZR_Emp02TP
  as select from zdrap_employeetb as Emp
  composition [0..*] of ZR_Skill01TP as _Skill
{
  key eid as EID,
  fname as Fname,
  lname as Lname,
  gender as Gender,
  dept as Dept,
  status as Status,
  doj as Doj,
  dol as Dol,
  salary as Salary,
  currency as Currency,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  _Skill
  
}


