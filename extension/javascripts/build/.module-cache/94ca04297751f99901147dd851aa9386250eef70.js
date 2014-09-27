/** @jsx React.DOM */

var UserAuth = React.createClass({displayName: 'UserAuth',

  getInitialState: function() {
    return {
      errors: [],
      showLogin: true,
      showRegister: false
    };
  },

  onClickRegister: function() {
    this.setState({showRegister: true, showLogin: false});
  },

  onClickLogin: function() {
    this.setState({showLogin: true, showRegister: false});
  },

  handleLoginRequest: function() {
    $.$.ajax({
      url: this.props.loginUrl,
      type: 'default GET (Other values: POST)',
      dataType: 'default: Intelligent Guess (Other values: xml, json, script, or html)',
      data: {param1: 'value1'},
    })
    .done(function() {
      console.log("success");
    })
    .fail(function() {
      console.log("error");
    })
    .always(function() {
      console.log("complete");
    });
    

  },

  handleRegisterRequest: function() {

  },

  render: function() {
    return (
      React.DOM.div({className: "userAuth"}, 
       this.state.showLogin ? LoginForm({onLogin: this.handleLoginRequest, onSwitchRegister: this.onClickRegister}) : null, 
       this.state.showRegister ? RegisterForm({onRegist: this.handleRegisterRequest, onSwitchLogin: this.onClickLogin}) : null
      )
    );
  }
});

var LoginForm = React.createClass({displayName: 'LoginForm',

  handleLogin: function(e) {
    e.preventDefault();
    var loginEmail = this.refs.loginEmail.getDOMNode().value.trim();
    var loginPassword = this.refs.loginPassword.getDOMNode().value.trim();
    this.refs.onLogin({loginEmail: loginEmail, loginPassword: loginPassword});
  },

  render: function() {
    return (
      React.DOM.div({className: "loginForm"}, 
      React.DOM.form({onSubmit: this.handleLogin}, 
        React.DOM.input({type: "text", placeholder: "Email", ref: "loginEmail"}), 
        React.DOM.input({type: "password", placeholder: "Password", ref: "loginPassword"}), 
        React.DOM.input({type: "submit"})
      ), 
      React.DOM.button({onClick: this.props.onSwitchRegister}, "Register")
      )
     );
  }
});

var RegisterForm = React.createClass({displayName: 'RegisterForm',
  render: function() {
    return (
      React.DOM.div({className: "registerForm"}, 
      React.DOM.form({onSubmit: this.handleRegister}, 
      React.DOM.input({type: "text", placeholder: "Name", ref: "registerName"}), 
      React.DOM.input({type: "text", placeholder: "Email", ref: "registerEmail"}), 
      React.DOM.input({type: "text", placeholder: "Password", ref: "registerPassword"}), 
      React.DOM.input({type: "submit"})
      ), 
      React.DOM.button({onClick: this.props.onSwitchLogin}, "Login")
      )
      );
  }
});

