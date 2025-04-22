@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forSkill'
@ObjectModel.usageType:{
    serviceQuality: #X, 
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_Skill01TP
  as select from zdrap_employeesk as Skill
  association to parent ZR_Emp02TP     as _Emp on $projection.EID = _Emp.EID
  composition [0..*] of ZR_SkillHistTP as _SkillHist
{
  key eid                   as EID,
  key sid                   as SID,
      sname                 as Sname,
      exp                   as Exp,
      hotskill              as Hotskill,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      _SkillHist,
      _Emp

}
