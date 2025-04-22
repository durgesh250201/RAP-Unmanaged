@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'CDS View forSkillHist'
define view entity ZR_SkillHistTP
  as select from ZDRAP_EMPLOYEESH as SkillHist
  association to parent ZR_Skill01TP as _Skill on $projection.EID = _Skill.EID and $projection.SID = _Skill.SID
  association [1] to ZR_Emp02TP as _Emp on $projection.EID = _Emp.EID
{
  key SID as SID,
  key SHID as ShID,
  key EID as EID,
  PROJNAME as Projname,
  PROJYEAR as Projyear,
  LOCAL_CREATED_BY as LocalCreatedBy,
  LOCAL_CREATED_AT as LocalCreatedAt,
  LOCAL_LAST_CHANGED_BY as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  LOCAL_LAST_CHANGED_AT as LocalLastChangedAt,
  LAST_CHANGED_AT as LastChangedAt,
  _Skill,
  _Emp
  
}
