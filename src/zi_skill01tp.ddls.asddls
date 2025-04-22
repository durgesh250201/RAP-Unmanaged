@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forSkill'
define view entity ZI_Skill01TP
  as projection on ZR_Skill01TP as Skill
{
  key EID,
  key SID,
  Sname,
  Exp,
  Hotskill,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  _SkillHist : redirected to composition child ZI_SkillHistTP,
  _Emp : redirected to parent ZI_Emp02TP
  
}
