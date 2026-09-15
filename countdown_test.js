// Mirrors the countdown in index.html. Fails loudly if the branching breaks.
function label(nowStr){
  var SHOW_Y=2027, SHOW_M=4, SHOW_D=29, RUNS_DAYS=2;
  var show=new Date(SHOW_Y,SHOW_M,SHOW_D);
  var today=new Date(nowStr); today.setHours(0,0,0,0);
  var days=Math.round((show-today)/86400000);
  return days>1 ? days+" days until the doors open"
       : days===1 ? "The show opens tomorrow"
       : (days<=0 && days>-RUNS_DAYS) ? "The show is on now" : "";
}
const cases = [
  ["2027-05-27T12:00:00", "2 days until the doors open"],
  ["2027-05-28T00:05:00", "The show opens tomorrow"],   // just after midnight
  ["2027-05-28T23:55:00", "The show opens tomorrow"],   // just before midnight
  ["2027-05-29T08:00:00", "The show is on now"],        // before doors, day 1
  ["2027-05-29T16:00:00", "The show is on now"],        // after doors, day 1
  ["2027-05-30T10:00:00", "The show is on now"],        // day 2
  ["2027-05-31T10:00:00", ""],                          // day after, gone
  ["2027-06-10T12:00:00", ""],
];
let bad = 0;
for (const [when, want] of cases){
  const got = label(when);
  const ok = got === want;
  if (!ok) bad++;
  console.log((ok?"ok  ":"FAIL")+"  "+when+"  -> "+JSON.stringify(got)+(ok?"":"   want "+JSON.stringify(want)));
}
if (bad) { console.log("\n"+bad+" FAILED"); process.exit(1); }
console.log("\ncountdown: all "+cases.length+" cases pass");
