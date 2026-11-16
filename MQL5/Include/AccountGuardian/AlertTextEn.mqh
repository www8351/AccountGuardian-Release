//+------------------------------------------------------------------+
//| AccountGuardian - AlertTextEn.mqh                                |
//| Every English message of the alerts service and its renderer: the|
//| twin of every function of AlertText.mqh that is not language     |
//| neutral, LANG-1. A twin has the signature of its Hebrew function,|
//| the name AgTgEn... for AgTg... and AgEn... for AgHe..., and the  |
//| same lines in the same order. Only the words and their order     |
//| differ, and the currency sign stands before the amount. The      |
//| neutral formatters (money, time, the currency sign, the HTML     |
//| escape and bold, the build line classes) stay in AlertText.mqh.  |
//| Every function here is a pure function of its arguments: no      |
//| file, no network call, no global variable, no clock. Shared by   |
//| the service and the vectors script. Saved as UTF-8 with a byte   |
//| order mark, the encoding AlertText.mqh carries, for the emoji.   |
//| No trade calls (SPEC 1).                                         |
//+------------------------------------------------------------------+
#ifndef AG_ALERT_TEXT_EN_MQH
#define AG_ALERT_TEXT_EN_MQH

#include <AccountGuardian/AlertText.mqh>

//--- every accepted text of the status command: the Hebrew text of TG-8 (B) first, then
//--- the three English texts, each matched whole by the service (LANG-2)
int AgTgAllCommandTexts(string &out[])
  {
   ArrayResize(out, 4);
   out[0] = AgTgCommandText();
   out[1] = "status";
   out[2] = "Status";
   out[3] = "/status";
   return 4;
  }

//--- the singular rule: the count and the plural noun, and at 1 the singular phrase given
string AgEnCount(const long n, const string plural, const string one)
  {
   if(n == 1)
      return one;
   return (string)n + " " + plural;
  }

string AgEnSeconds(const long n)   { return AgEnCount(n, "seconds", "1 second"); }

string AgEnPositions(const long n) { return AgEnCount(n, "positions", "1 position"); }

string AgEnPendings(const long n)  { return AgEnCount(n, "pending orders", "1 pending order"); }

string AgEnAttempts(const long n)  { return AgEnCount(n, "attempts", "1 attempt"); }

//--- an amount with its currency before it: a symbol at once, a code and a space
string AgTgEnWithCurrency(const string amount, const string cur)
  {
   if(cur == "")
      return amount;
   if(StringLen(cur) == 1)
      return cur + amount;
   return cur + " " + amount;
  }

//--- the signed day result with its currency: the sign first, a plus above zero, a minus
//--- below, none at zero, so a figure that prints 0.00 carries no sign
string AgTgEnSignedWithCurrency(const double v, const string cur)
  {
   double r = MathRound(v * 100.0) / 100.0;
   string sign = r > 0.0 ? "+" : (r < 0.0 ? "-" : "");
   return sign + AgTgEnWithCurrency(AgTgMoneyText(MathAbs(r)), cur);
  }

//--- 2 decimals, a "Profit" or "Loss" word by the sign, rounded first, so a figure that
//--- prints 0.00 always reads as a loss of 0.00
string AgTgEnSigned(const double v)
  {
   double r = MathRound(v * 100.0) / 100.0;
   if(r > 0.0)
      return "Profit " + AgTgMoneyText(r);
   return "Loss " + AgTgMoneyText(-r);
  }

//--- under 120 s in seconds, under 120 minutes in minutes, longer in hours and minutes
string AgTgEnDuration(const long seconds)
  {
   if(seconds < 120)
      return AgEnSeconds(seconds);
   if(seconds < 7200)
      return (string)(seconds / 60) + " minutes";
   long   minutes = (seconds % 3600) / 60;
   string out = (string)(seconds / 3600) + " hours";
   if(minutes == 1)
      return out + " and 1 minute";
   if(minutes > 1)
      return out + " and " + (string)minutes + " minutes";
   return out;
  }

//--- the life sign line's age: "just now" under 5 s, else the duration and "ago"
string AgTgEnAgo(const long seconds) { return seconds < 5 ? "just now" : AgTgEnDuration(seconds) + " ago"; }

string AgTgEnStateWord(const int state)
  {
   switch(state)
     {
      case AG_STATE_ACTIVE:    return "Active";
      case AG_STATE_LOCKED:    return "Locked";
      case AG_STATE_SYNCING:   return "Syncing";
      case AG_STATE_SAFE_HALT: return "Safe halt";
     }
   return "Not running";
  }

//--- the limit line (F2); figures taken under a lock carry the locked wording
string AgTgEnLimitLine(const int mode, const double limit)
  {
   return (mode == AG_TG_PNL_LOCKED ? "⚙️ Locked daily limit: " : "⚙️ Daily limit: ") + AgTgMoneyText(limit);
  }

//--- the day result line (R3): the total PNL, signed, with the currency's
//--- sign; U+1F4C8 above zero and U+1F4C9 otherwise, so a result that
//--- prints 0.00 and one not computed yet take U+1F4C9
string AgTgEnResultLine(const int mode, const double pnl, const string cur)
  {
   if(mode == AG_TG_PNL_NONE)
      return "📉 Total PNL: not computed yet";
   double r = MathRound(pnl * 100.0) / 100.0;
   return (r > 0.0 ? "📈 Total PNL: " : "📉 Total PNL: ") + AgTgEnSignedWithCurrency(r, cur);
  }

//--- the limit and the result group (addendum 1.2); not computed yet, the
//--- result line alone, there being no limit to show
string AgTgEnPnlLine(const int mode, const double pnl, const double limit, const string cur)
  {
   if(mode == AG_TG_PNL_NONE)
      return AgTgEnResultLine(mode, pnl, cur);
   return AgTgEnLimitLine(mode, limit) + "\n" + AgTgEnResultLine(mode, pnl, cur);
  }

//--- the open trades line (R4): the open positions, none at zero
string AgTgEnOpenLine(const long open_pos)
  {
   return "📂 Open trades: " + (open_pos > 0 ? (string)open_pos : "none");
  }

//--- the account and the time, then the money, the open trades line last
//--- unless open_line is false (R4)
string AgTgEnCommonHead(const AgTgCommon &c, const bool open_line)
  {
   return "👤 Account number: " + (string)c.login
        + "\n🕒 Time: " + AgTgStamp(c.server_t)
        + "\n\n💰 Balance: " + AgTgMoneyText(c.balance)
        + "\n💵 Equity: " + AgTgMoneyText(c.equity)
        + (open_line ? "\n" + AgTgEnOpenLine(c.open_pos) : "");
  }

//--- the common lines whole: the head, the limit and the result, the state
string AgTgEnCommonLines(const AgTgCommon &c)
  {
   return AgTgEnCommonHead(c, true) + "\n\n" + AgTgEnPnlLine(c.pnl_mode, c.pnl, c.limit, c.cur)
        + "\n\n🛡️ State: " + AgTgEnStateWord(c.state);
  }

//--- a headline, the common lines with the limit and result group given,
//--- then the event lines given; open_line false in the lock messages whose
//--- sweep line gives the count (R4)
string AgTgEnMessageWith(const string headline, const AgTgCommon &c, const string group, const string events,
                       const bool open_line)
  {
   return headline + "\n\n" + AgTgEnCommonHead(c, open_line) + "\n\n" + group + "\n\n🛡️ State: " + AgTgEnStateWord(c.state)
        + (events == "" ? "" : "\n" + events);
  }

//--- a headline, the common lines, then the event lines given
string AgTgEnMessage(const string headline, const AgTgCommon &c, const string events)
  {
   return AgTgEnMessageWith(headline, c, AgTgEnPnlLine(c.pnl_mode, c.pnl, c.limit, c.cur), events, true);
  }

//--- the deinit reason, 0 to 9 (plan 3.2); anything else was not recorded
string AgTgEnReasonWord(const int reason)
  {
   switch(reason)
     {
      case 0: return "the guardian stopped itself";
      case 1: return "the guardian was removed from the chart";
      case 2: return "the guardian was recompiled";
      case 3: return "the chart's symbol or timeframe was changed";
      case 4: return "the chart was closed";
      case 5: return "the guardian's settings were changed";
      case 6: return "the account in the terminal was changed or its connection was reset";
      case 7: return "a template was applied to the chart";
      case 8: return "the start failed";
      case 9: return "the terminal was closed";
     }
   return "not recorded";
  }

//--- the account wide block, in the AgTradeBlockName order
string AgTgEnBlockWord(const int code)
  {
   switch(code)
     {
      case 1: return "the Algo Trading button in the terminal is off";
      case 2: return "Allow Algo Trading is off in the guardian's settings";
      case 3: return "the account does not allow trading. You may be logged in with an investor password";
      case 4: return "the broker does not allow algorithmic trading on this account";
     }
   return "the Algo Trading button in the terminal is off";
  }

//--- S16's lock source: the reason first, then the local witnesses, then history
string AgTgEnSourceWord(const int reason, const int mask)
  {
   if(reason == AG_LOCK_CORRUPT_STATE)
      return "the lock state file is corrupt, so the lock lasts until the start of the next trading day";
   if((mask & 1) != 0 && (mask & 2) != 0)
      return "the lock state file and the backup variable in the terminal";
   if((mask & 1) != 0)
      return "the lock state file";
   if((mask & 2) != 0)
      return "the backup variable in the terminal";
   if(reason == AG_LOCK_SWEEP_WITNESS)
      return "the guardian's own closing deals of today";
   return "the deal history on the server";
  }

//--- S17's file, by the kind the EA reports
string AgTgEnFileWord(const int kind)
  {
   switch(kind)
     {
      case 1: return "the lock state file";
      case 2: return "the halt file";
      case 3: return "the file that holds the limit against a raise";
      case 4: return "the closed profit peak file";
      case 5: return "the alert queue file";
      case 6: return "the Manual Lockout file";
     }
   return "one of the guardian's files";
  }

//--- the limit line carries both legs; the line of the limit in force is
//--- gone (F7), the limit line showing the same value
string AgTgEnTextS1(const AgTgCommon &c, const double percent, const double currency, const double enforced,
                  const string cur)
  {
   string group = AgTgEnLimitLine(c.pnl_mode, c.limit) + ", the lower of " + AgTgMoney(percent)
                + "% of the balance at the start of the day and " + AgTgEnWithCurrency(AgTgNum(currency), cur)
                + "\n" + AgTgEnResultLine(c.pnl_mode, c.pnl, c.cur);
   return AgTgEnMessageWith("🟢 The guardian started and is protecting the account", c, group, "🔓 Lock: none", true);
  }

string AgTgEnTextS1Restarted(const AgTgCommon &c, const int reason)
  {
   return AgTgEnMessage("🟢 The guardian restarted", c,
                      "🔄 Restart reason: " + AgTgEnReasonWord(reason)
                      + "\n🔓 Lock: none");
  }

string AgTgEnTextS2(const AgTgCommon &c, const int reason)
  {
   AgTgCommon k = c;
   k.state = AG_TG_STATE_NOT_RUNNING;
   return AgTgEnMessage("🔴 The guardian stopped", k,
                      "📝 Reason: " + AgTgEnReasonWord(reason)
                      + "\n🚫 The account is not protected until the guardian starts again");
  }

string AgTgEnTextS3Refused(const AgTgCommon &c)
  {
   return AgTgEnMessage("⛔ The guardian refused to start", c,
                      "📝 Reason: the daily limit value is not in the allowed list"
                      "\n🚫 The account is not protected until the setting is fixed and the guardian is attached again");
  }

string AgTgEnTextS3Second(const AgTgCommon &c)
  {
   return AgTgEnMessage("⛔ A second copy of the guardian refused to start", c,
                      "📝 Reason: another copy of the guardian is already running on the account"
                      "\n👍 The existing copy keeps protecting the account");
  }

string AgTgEnTextS3Crash(const AgTgCommon &c, const long chain, const long window_seconds)
  {
   return AgTgEnMessage("🛑 Safe halt: the guardian crashed repeatedly", c,
                      "💥 " + AgEnCount(chain, "starts", "1 start") + " in a row ended without a clean stop, at most "
                      + AgTgEnDuration(window_seconds) + " apart"
                      + "\n🚫 The account is not protected, and the guardian will not close anything"
                      + "\n👉 To resume: stop the guardian, delete the halt file and start it again");
  }

string AgTgEnTextS3Persisted(const AgTgCommon &c, const datetime halt_time)
  {
   return AgTgEnMessage("🛑 Safe halt continues after a restart", c,
                      "⏸️ The halt started at " + AgTgStamp(halt_time)
                      + "\n🚫 The account is not protected until the guardian is resumed manually");
  }

//--- the sweep line every lock message carries; a zero count is left out,
//--- and with both zero the line is (F6)
string AgTgEnSweepNow(const long positions, const long pendings)
  {
   if(positions > 0 && pendings > 0)
      return "🧹 Closing " + AgEnPositions(positions) + " and deleting " + AgEnPendings(pendings) + " now";
   if(positions > 0)
      return "🧹 Closing " + AgEnPositions(positions) + " now";
   if(pendings > 0)
      return "🧹 Deleting " + AgEnPendings(pendings) + " now";
   return "";
  }

//--- F8: the crossed limit in its own unit, kind 1 the percent leg, 2 the
//--- currency leg, 3 the held floor; the signed day result takes the place
//--- of the day result line, and the message ends with the day done; no
//--- open trades line, the sweep line giving the count (R4)
string AgTgEnTextS4(const AgTgCommon &c, const int kind, const datetime until, const double percent,
                  const double currency, const double pnl_at_lock, const long positions,
                  const long pendings, const string cur)
  {
   string crossed = AgTgEnWithCurrency(AgTgMoneyText(c.limit), cur);
   if(kind == 1)
      crossed = AgTgMoney(percent) + "%";
   else if(kind == 2)
      crossed = AgTgEnWithCurrency(AgTgNum(currency), cur);
   string group = AgTgEnLimitLine(c.pnl_mode, c.limit)
                + "\n🚨 Daily loss limit crossed: " + crossed
                + "\n📉 Total PNL: " + AgTgEnSignedWithCurrency(pnl_at_lock, cur);
   string events = AgTgAdd("⏳ Locked until: " + AgTgStamp(until), AgTgEnSweepNow(positions, pendings));
   return AgTgEnMessageWith("🔒 Account locked: daily limit exceeded", c, group, events + "\n🏁 Done for today", false);
  }

//--- kind 4, the give back from the daily peak, which keeps its own wording
string AgTgEnTextS4Peak(const AgTgCommon &c, const datetime until, const double peak,
                      const double threshold, const double pnl_at_lock, const long positions,
                      const long pendings, const string cur)
  {
   string group = AgTgEnLimitLine(c.pnl_mode, c.limit)
                + "\n🏔️ Closed profit peak today: " + AgTgMoneyText(peak)
                + "\n🎯 Lock threshold: " + AgTgEnSigned(threshold)
                + "\n📉 Total PNL: " + AgTgEnSignedWithCurrency(pnl_at_lock, cur);
   string events = AgTgAdd("⏳ Locked until: " + AgTgStamp(until), AgTgEnSweepNow(positions, pendings));
   return AgTgEnMessageWith("🔒 Account locked: drawdown from the daily profit peak", c, group, events + "\n🏁 Done for today", false);
  }

//--- the Manual Lockout's note (ML-8): a lockout that ends before the next
//--- daily anchor says what a close by the guardian does; none at the anchor
string AgTgEnManualNote(const datetime end, const datetime anchor, const long positions)
  {
   if(end >= anchor)
      return "";
   if(positions > 0)
      return "ℹ️ The guardian is closing the open trades now, so the account stays locked until the start of the next trading day";
   return "ℹ️ If the guardian closes a trade during the lock, the account stays locked until the start of the next trading day";
  }

//--- S5, the Manual Lockout engaged (ML-17 (A)), sent at the engagement only
//--- (ML-30). It carries the sweep line and leaves the open trades line out,
//--- as S4 and S16 do (R4, ML-31).
string AgTgEnTextS5(const AgTgCommon &c, const datetime end, const datetime anchor, const long length,
                  const long positions, const long pendings)
  {
   string lines = "⏳ Locked until: " + AgTgStamp(end) + "\n⌛ Duration: " + AgTgEnDuration(length);
   lines = AgTgAdd(lines, AgTgEnSweepNow(positions, pendings));
   lines += "\n❗ The lock cannot be canceled or shortened";
   lines = AgTgAdd(lines, AgTgEnManualNote(end, anchor, positions));
   return AgTgEnMessageWith("🔒 Manual Lockout: the account is locked at your request", c, AgTgEnPnlLine(c.pnl_mode, c.pnl, c.limit, c.cur),
                          lines, false);
  }

string AgTgEnTextS6C(const AgTgCommon &c, const long closed, const long deleted, const long attempts,
                   const long failures, const long seconds)
  {
   string lines = "";
   if(closed > 0)
      lines = AgTgAdd(lines, "📤 Closed: " + AgEnPositions(closed));
   if(deleted > 0)
      lines = AgTgAdd(lines, "🗑️ Deleted: " + AgEnPendings(deleted));
   if(attempts > 0)
      lines = AgTgAdd(lines, "🔢 Number of send attempts: " + (string)attempts);
   if(failures > 0)
      lines = AgTgAdd(lines, "❌ Number of failures: " + (string)failures);
   lines = AgTgAdd(lines, "⌛ Duration: " + AgTgEnDuration(seconds));
   return AgTgEnMessage("🧹 Finished closing positions", c, lines);
  }

//--- the ticket line and the symbol line of a position or a pending order
string AgTgEnTicketLines(const ulong ticket, const bool is_order, const string symbol)
  {
   return (is_order ? "🎫 Order ticket: " : "🎫 Position ticket: ") + (string)ticket
        + (symbol == "" ? "" : "\n🏷️ " + symbol);
  }

//--- reason 1 session closed, 2 hard stop, 3 refuse, 4 trade mode disabled,
//--- 5 a hold class retcode; next_open 0 when unknown
string AgTgEnTextS6H(const AgTgCommon &c, const ulong ticket, const bool is_order, const int reason,
                   const string symbol, const datetime next_open, const long hard_stop,
                   const long rearm_seconds)
  {
   string what = is_order ? "Pending order not deleted" : "Position not closed";
   string lines = AgTgEnTicketLines(ticket, is_order, symbol);
   if(reason == 1)
      return AgTgEnMessage("⚠️ " + what + ": the market is closed for this symbol", c,
                         lines + "\n" + (next_open > 0
                                         ? "🔁 Retry when the market opens: " + AgTgStamp(next_open)
                                         : "🔁 Retry when the market opens"));
   if(reason == 4)
      return AgTgEnMessage("⚠️ " + what + ": trading in this symbol is disabled", c,
                         lines + "\n🔁 Retry when trading in this symbol is allowed again");
   if(reason == 2)
      return AgTgEnMessage("⚠️ " + what + " after " + AgEnAttempts(hard_stop), c,
                         lines + "\n🔁 The guardian will try again every " + AgTgEnDuration(rearm_seconds));
   return AgTgEnMessage("⚠️ " + what + ": the server did not carry out " + (is_order ? "the deletion" : "the close"), c,
                      lines + "\n🔁 The guardian will try again every " + AgTgEnDuration(rearm_seconds));
  }

string AgTgEnTextS6F(const AgTgCommon &c, const ulong ticket, const bool is_order, const string symbol)
  {
   return AgTgEnMessage(is_order ? "🧹 A pending order that could not be deleted earlier is now deleted"
                               : "🧹 A position that could not be closed earlier is now closed",
                      c, AgTgEnTicketLines(ticket, is_order, symbol));
  }

string AgTgEnTextS7(const AgTgCommon &c, const ulong ticket, const string symbol, const long attempt)
  {
   return AgTgEnMessage("🧹 A trade opened during the lock was closed", c,
                      AgTgEnTicketLines(ticket, false, symbol) + "\n"
                      + (attempt <= 1 ? "🔢 Closed on the first attempt" : "🔢 Closed on attempt number " + (string)attempt));
  }

string AgTgEnTextS8Released(const AgTgCommon &c, const datetime expired, const double new_limit)
  {
   return AgTgEnMessage("🔓 The lock ended: a new trading day started", c,
                      "⏰ The lock ended at " + AgTgStamp(expired)
                      + "\n🆕 Limit for the new trading day: " + AgTgMoneyText(new_limit));
  }

string AgTgEnTextS8Again(const AgTgCommon &c, const datetime until)
  {
   return AgTgEnMessage("🔒 The lock was renewed on the new trading day", c,
                      "ℹ️ The open loss still exceeds the new day's limit"
                      "\n⏳ Locked until: " + AgTgStamp(until));
  }

string AgTgEnTextS9(const AgTgCommon &c, const long level, const double room)
  {
   return AgTgEnMessage("⚠️ Approaching the daily limit", c,
                      "🌡️ " + (string)level + "% of the limit used"
                      + "\n📏 Remaining before a lock: " + AgTgMoneyText(room)
                      + "\nℹ️ This is only a warning. The account is not locked");
  }

string AgTgEnTextS10(const AgTgCommon &c, const datetime lost, const datetime back, const long gap)
  {
   return AgTgEnMessage("📶 The connection to the broker server is back", c,
                      "⏰ The connection was lost at " + AgTgStamp(lost)
                      + "\n⏰ The connection came back at " + AgTgStamp(back)
                      + "\n⌛ Time disconnected: " + AgTgEnDuration(gap)
                      + "\nℹ️ While disconnected, the guardian made no lock decisions and sent no orders");
  }

string AgTgEnTextS11(const AgTgCommon &c, const datetime from_local, const datetime to_local, const long held)
  {
   string lines = "⏰ Telegram was unavailable from " + AgTgStamp(from_local) + " to " + AgTgStamp(to_local);
   if(held > 0)
      lines += "\n📬 Number of delayed alerts: " + (string)held;
   return AgTgEnMessage("📨 Delayed alerts are being sent now", c,
                      lines + "\nℹ️ The delayed alerts are sent right after this message");
  }

//--- the line under the block follows the guardian's state at the edge:
//--- LOCKED keeps checking, ACTIVE warns, SYNCING and SAFE_HALT add nothing
string AgTgEnTextS12Blocked(const AgTgCommon &c, const int code)
  {
   string events = "🚧 Block: " + AgTgEnBlockWord(code);
   if(c.state == AG_STATE_LOCKED)
      events += "\n🔁 The guardian keeps checking and will close positions as soon as trading is back";
   else if(c.state == AG_STATE_ACTIVE)
      events += "\n❗ Blocked while the account is active: if the limit is crossed, the guardian will not be able to close positions";
   return AgTgEnMessage("⛔ Algorithmic trading is blocked: the guardian cannot close positions", c, events);
  }

string AgTgEnTextS12Restored(const AgTgCommon &c)
  {
   return AgTgEnMessage("✅ Algorithmic trading is back", c, "👍 The guardian can close positions again");
  }

string AgTgEnTextS14(const AgTgCommon &c, const datetime day_anchor, const double closed_result,
                   const double peak, const long locks, const double new_limit)
  {
   string lines = "📅 Trading day ended: " + AgTgDate(day_anchor)
                + "\n🧾 Closed result for that day: " + AgTgEnSigned(closed_result)
                + "\n🏔️ Closed profit peak for that day: " + AgTgMoneyText(peak);
   if(locks > 0)
      lines += "\n🔐 Number of locks that day: " + (string)locks;
   return AgTgEnMessage("📊 Trading day summary", c, lines + "\n🆕 Limit for the new trading day: " + AgTgMoneyText(new_limit));
  }

string AgTgEnTextS15(const AgTgCommon &c)
  {
   return AgTgEnMessage("🟢 The guardian resumed after a safe halt", c,
                      "🛠️ The halt file was deleted manually, as the resume procedure requires");
  }

//--- restart_reason is the in place stop it merges with, -1 when none; no
//--- open trades line, the sweep line giving the count (R4)
string AgTgEnTextS16(const AgTgCommon &c, const datetime until, const int reason, const int mask,
                   const long positions, const long pendings, const int restart_reason)
  {
   string lines = (restart_reason >= 0 ? "🔄 Restart reason: " + AgTgEnReasonWord(restart_reason) + "\n" : "")
                + "⏳ Locked until: " + AgTgStamp(until)
                + "\n🔎 Lock source: " + AgTgEnSourceWord(reason, mask);
   return AgTgEnMessageWith("🔒 The lock was restored when the guardian started", c, AgTgEnPnlLine(c.pnl_mode, c.pnl, c.limit, c.cur),
                          AgTgAdd(lines, AgTgEnSweepNow(positions, pendings)), false);
  }

//--- how 1 a write failed, 2 quarantined at load
string AgTgEnTextS17(const AgTgCommon &c, const int kind, const int how)
  {
   if(how == 2)
      return AgTgEnMessage("⚠️ The guardian found a corrupt file", c,
                         "📁 File: " + AgTgEnFileWord(kind)
                         + "\nℹ️ The file was moved to quarantine and a new file was created");
   return AgTgEnMessage("⚠️ The guardian could not save a file", c,
                      "📁 File: " + AgTgEnFileWord(kind)
                      + (kind == 1 ? "\n❗ Until the next start, the lock is kept in memory only" : ""));
  }

string AgTgEnTextS18(const AgTgCommon &c, const long seconds)
  {
   return AgTgEnMessage("⚠️ The guardian's previous session was cut off", c,
                      "⌛ The guardian was not running for " + AgTgEnDuration(seconds) + " before this start"
                      + "\n📝 Possible reason: a computer shutdown, a crash or a forced close");
  }

//--- which: 1 the percent input changed, 2 the currency input, 3 both; the
//--- percent leg as a percent, the currency leg with its currency
string AgTgEnTextS19Locked(const AgTgCommon &c, const int which, const double percent,
                         const double currency, const double snap, const string cur)
  {
   string entered = ((which & 1) != 0) ? AgTgMoney(percent) + "%" : AgTgEnWithCurrency(AgTgNum(currency), cur);
   return AgTgEnMessage("⚠️ Limit change blocked", c,
                      "✏️ Limit entered: " + entered
                      + "\n📌 Limit in force until the lock ends: " + AgTgMoneyText(snap));
  }

string AgTgEnTextS19Raise(const AgTgCommon &c, const double live, const double enforced)
  {
   return AgTgEnMessage("⚠️ The raised limit takes effect only on the next trading day", c,
                      "✏️ Limit entered: " + AgTgMoneyText(live)
                      + "\n📌 Limit in force today: " + AgTgMoneyText(enforced));
  }

string AgTgEnTextS20(const AgTgCommon &c, const long jump)
  {
   return AgTgEnMessage("⚠️ The server clock jumped by more than one day", c,
                      "⏩ The start of the day jumped by " + AgTgEnDuration(jump)
                      + "\nℹ️ The guardian continues calculating from the new day");
  }

string AgTgEnTextS21(const AgTgCommon &c)
  {
   return AgTgEnMessage("⚠️ Reading the deal history failed", c,
                      "ℹ️ The guardian makes no lock decisions until the read succeeds, and retries every second");
  }

//--- why: 1 no broker connection, 2 history not stable yet
string AgTgEnTextS22(const AgTgCommon &c, const long seconds, const int why)
  {
   return AgTgEnMessage("⚠️ The guardian is not protecting the account yet", c,
                      "⌛ The guardian has been syncing for " + AgTgEnDuration(seconds)
                      + "\n📝 Reason: " + (why == 1 ? "no connection to the broker server" : "the deal history is not stable yet"));
  }

string AgTgEnTextS24(const AgTgCommon &c)
  {
   return AgTgEnMessage("⛔ Another copy of the guardian took over the account", c,
                      "👥 Another copy of the guardian registered itself as running on the same account"
                      "\n👉 Make sure the guardian is attached to one chart only");
  }

//--- S25's why line: the lock that holds the account after the lockout's
//--- own end, by its reason (ML-7, ML-8)
string AgTgEnManualAgainWord(const int reason)
  {
   if(reason == AG_LOCK_SWEEP_WITNESS)
      return "ℹ️ The guardian closed a trade during the Manual Lockout, so the account is locked until the start of the next trading day";
   if(reason == AG_LOCK_DAILY_BREACH)
      return "ℹ️ The day's loss exceeds the daily limit";
   if(reason == AG_LOCK_CORRUPT_STATE)
      return "ℹ️ The lock state file is corrupt, so the lock lasts until the start of the next trading day";
   return "";
  }

//--- S25, the Manual Lockout's own end (ML-17 (A)): outcome 1 released, 2
//--- the account stays locked by the lock that holds it now, until its end
string AgTgEnTextS25(const AgTgCommon &c, const int outcome, const datetime end, const datetime until,
                   const int reason)
  {
   if(outcome == 1)
      return AgTgEnMessage("🔓 The Manual Lockout ended", c, "⏰ The lock ended at " + AgTgStamp(end));
   string lines = AgTgAdd("⏰ The lock ended at " + AgTgStamp(end), AgTgEnManualAgainWord(reason));
   return AgTgEnMessage("🔒 The Manual Lockout ended, but the account stays locked", c, lines + "\n⏳ Locked until: " + AgTgStamp(until));
  }

string AgTgEnTextStatus(const AgTgCommon &c, const long hb_age, const long data_age, const datetime until)
  {
   string headline = "🔴 The guardian is not running and is not protecting the account";
   if(c.state == AG_STATE_ACTIVE)
      headline = "🟢 The guardian is running and protecting the account";
   else if(c.state == AG_STATE_LOCKED)
      headline = "🔒 The guardian is running and the account is locked";
   else if(c.state == AG_STATE_SYNCING)
      headline = "⚠️ The guardian is running but is not protecting the account yet";
   else if(c.state == AG_STATE_SAFE_HALT)
      headline = "🛑 The guardian is in a safe halt and is not protecting the account";
   string events = "";
   if(c.state == AG_TG_STATE_NOT_RUNNING)
     {
      if(hb_age >= 0)
         events = "💔 The guardian has not updated its heartbeat for " + AgTgEnDuration(hb_age);
      return AgTgEnMessage(headline, c, events);
     }
   if(c.state == AG_STATE_ACTIVE)
      events = "🔓 Lock: none";
   else if(c.state == AG_STATE_LOCKED)
      events = "⏳ Locked until: " + AgTgStamp(until);
   events = AgTgAdd(events, "💓 Heartbeat: " + AgTgEnAgo(hb_age < 0 ? 0 : hb_age));
   if(data_age >= 0)
      events = AgTgAdd(events, "📡 Last data update from the guardian: " + AgTgEnDuration(data_age) + " ago");
   return AgTgEnMessage(headline, c, events);
  }

//--- not_recorded: released with no stop event; ping_on: the network
//--- heartbeat channel is on, so its pings stop with this
string AgTgEnTextNotResponding(const AgTgCommon &c, const long seconds, const bool not_recorded,
                             const bool ping_on)
  {
   AgTgCommon k = c;
   k.state = AG_TG_STATE_NOT_RUNNING;
   return AgTgEnMessage("⛔ The guardian stopped responding", k,
                      "💔 The guardian has not updated its heartbeat for " + AgTgEnDuration(seconds)
                      + (not_recorded ? "\n📝 Reason: not recorded" : "")
                      + "\n🚫 The terminal is running, but the guardian is not protecting the account"
                      + (ping_on ? "\n📴 The heartbeat to the external monitoring service has stopped" : ""));
  }

string AgTgEnTextNotRunning(const AgTgCommon &c, const long seconds)
  {
   AgTgCommon k = c;
   k.state = AG_TG_STATE_NOT_RUNNING;
   return AgTgEnMessage("⛔ The guardian is not running in the terminal", k,
                      "⌛ The alerts service has been running for " + AgTgEnDuration(seconds) + " and the guardian has not started yet"
                      + "\n🚫 The account is not protected until the guardian is attached to a chart");
  }

string AgTgEnTextRespondsAgain(const AgTgCommon &c, const long gap)
  {
   return AgTgEnMessage("✅ The guardian is responding again", c, "⌛ The guardian did not respond for " + AgTgEnDuration(gap));
  }

string AgTgEnFinish(const string text, const long not_kept, const long held_back, const long delay_seconds,
                  const string build_line)
  {
   string closing = "";
   if(not_kept > 0)
      closing = AgTgAdd(closing, "📭 Alerts dropped because of overload: " + (string)not_kept);
   if(held_back > 0)
      closing = AgTgAdd(closing, "🔇 Number of similar events not sent since the previous message: " + (string)held_back);
   if(delay_seconds > 0)
      closing = AgTgAdd(closing, "⏱️ Sent " + AgTgEnDuration(delay_seconds) + " late");
   string out = text + (closing == "" ? "" : "\n\n" + closing);
   return build_line == "" ? out : out + "\n" + build_line;
  }

#endif // AG_ALERT_TEXT_EN_MQH
