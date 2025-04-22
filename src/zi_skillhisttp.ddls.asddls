@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Projection View forSkillHist'
define view entity ZI_SkillHistTP
  as projection on ZR_SkillHistTP as SkillHist
{
  key SID,
  key ShID,
  key EID,
  Projname,
  Projyear,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  LastChangedAt,
  _Skill : redirected to parent ZI_Skill01TP,
  _Emp : redirected to ZI_Emp02TP
  
}
