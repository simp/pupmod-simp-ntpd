# ntp ``restrict`` options
type Ntpd::Restrict = Enum[
  'flake',
  'ignore',
  'kod',
  'limited',
  'lowpriotrap',
  'mssntp',
  'nomodify',
  'non-ntpport',
  'nopeer',
  'noquery',
  'noserve',
  'notrap',
  'notrust',
  'ntpport',
  'version'
]
