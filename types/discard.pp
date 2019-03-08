# ntp ``discard`` options
type Ntpd::Discard = Struct[{
  Optional[average] => Integer[0],
  Optional[minimum] => Integer[0],
  Optional[monitor] => Integer[1]
}]
