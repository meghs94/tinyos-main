//$Id: TimerToAlarmM.nc,v 1.1.2.3 2005-04-22 06:11:12 cssharp Exp $

/* "Copyright (c) 2000-2003 The Regents of the University of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

// @author Cory Sharp <cssharp@eecs.berkeley.edu>

// Convert a Timer into an Alarm, can be used to re-Multiplex a Timer, etc.

generic module TimerToAlarmM( typedef frequency_tag, typedef size_type @integer() )
{
  provides interface AlarmBase<frequency_tag,size_type> as AlarmBase;
  uses interface TimerBase<frequency_tag,size_type> as TimerBase;
}
implementation
{
  async command void AlarmBase.startNow( uint32_t dt )
  {
    return call TimerBase.startOneShotNow( dt );
  }

  async command void AlarmBase.stop()
  {
    return call TimerBase.stop();
  }

  async event void TimerBase.fired( size_type when, size_type numMissed )
  {
    signal AlarmBase.fired();
  }

  default async event void AlarmBase.fired()
  {
  }

  async command bool AlarmBase.isRunning()
  {
    return call TimerBase.isRunning();
  }

  async command void AlarmBase.start( uint32_t t0, uint32_t dt )
  {
    return call TimerBase.startOneShot(t0,dt);
  }

  async command uint32_t AlarmBase.getNow()
  {
    return call TimerBase.getNow();
  }

  async command uint32_t AlarmBase.getAlarm()
  {
    return call call TimerBase.gett0() + call TimerBase.getdt();
  }
}

