package Dashboard;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Digest::SHA1 qw(sha1_hex);

=head

Check if the user has authorization for this part of the web site

=cut

hook 'before' => sub {
  my $user = session('user');

  redirect('/') if ( !$user );
};

=head

Dashboard index

=cut

any '/dashboard' => sub {

  my $user = session('user');

  if ( $user->status eq 'deactivated' ) {

    if ( params->{password1} ) {
      my $password1 = params->{password1};
      my $password2 = params->{password2};

      if ( $password1 ne $password2 ) {
        template 'admin/index', { user => $user, warning => 'The passwords don\'t match!' }, { layout => 'admin' };
      }
      else {
        $user->update({
          password => sha1_hex( $password1 ),
          status   => 'activated'
        });

        template 'admin/index', { user => $user }, { layout => 'admin' };
      }
    }
    else {
      template 'admin/index', { user => $user }, { layout => 'admin' };
    }
  }
  else {
    redirect('/admin/posts/add') if ( $user->is_admin );
    redirect('/author/posts/add');
  }

};

=head

Edit profile

=cut

any '/profile' => sub {

  my $user = session('user');

  my $first_name     = params->{first_name};
  my $last_name     = params->{last_name};
  my $email       = params->{email};

  my $old_password   = params->{old_password};
  my $new_password   = params->{new_password};
  my $new_password2   = params->{new_password2};

  if ( $first_name && $last_name && $email ) {

    $user->update({
        first_name   => $first_name,
        last_name   => $last_name,
        email     => $email
      });

    template 'admin/profile', { user => $user, success => 'Your data was updated succesfully!' }, { layout => 'admin' };

  }
  elsif ( $old_password && $new_password && $new_password2 ) {

    if ( sha1_hex($old_password) ne $user->password ) {

      template 'admin/profile', { user => $user, warning => 'Incorrect old password!' }, { layout => 'admin' };

    }
    elsif ( $new_password ne $new_password2 ) {

      template 'admin/profile', { user => $user, warning => 'The new passwords don\'t match!' }, { layout => 'admin' };

    }
    else {

      $user->update({ password => sha1_hex($new_password) });

      template 'admin/profile', { user => $user, success => 'The password was changed succesfully!' }, { layout => 'admin' };
    }
  }
  else {

    template 'admin/profile', { user => $user }, { layout => 'admin' };

  }

};

1;