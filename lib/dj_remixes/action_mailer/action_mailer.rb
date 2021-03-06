module Mail
  class Message
    
    class MailmanWorker < DJ::Worker
      priority :urgent
      run_at {1.year.ago}

      def perform   
        # Force loading of the class first to avoid the dreaded 'undefined class/module' error
        eval(self.klass)
        message = Marshal.load(self.mail)
        message.deliver_without_worker
      end
    end # MailmanWorker
    
    def deliver_with_worker
      if ActionMailer::Base.delivery_method == :test
        deliver_without_worker
      else
        puts self
        Mail::Message::MailmanWorker.enqueue(:mail => Marshal.dump(self), :klass => self.delivery_handler.name)
        return self
      end
    end
    
    alias_method_chain :deliver, :worker
    
  end # Message
end # Mail